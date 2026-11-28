using Backend.Domain.Geography;
using Backend.Domain.Identity;
using Backend.Domain.Providers;
using Backend.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite;
using NetTopologySuite.Geometries;
using Npgsql;
using Testcontainers.PostgreSql;

namespace Backend.IntegrationTests.Persistence;

public class CorePostgreSqlIntegrationTests : IAsyncLifetime
{
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder("postgis/postgis:16-3.4").Build();

    private readonly GeometryFactory _geometryFactory =
        NtsGeometryServices.Instance.CreateGeometryFactory(srid: 4326);

    private AppDbContext _db = null!;

    public async Task InitializeAsync()
    {
        await _postgres.StartAsync();

        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(
                _postgres.GetConnectionString(),
                npgsql => npgsql.UseNetTopologySuite())
            .Options;

        _db = new AppDbContext(options);
        await _db.Database.EnsureCreatedAsync();
    }

    public async Task DisposeAsync()
    {
        if (_db is not null)
        {
            await _db.DisposeAsync();
        }

        await _postgres.DisposeAsync();
    }

    [Fact]
    public async Task ProviderAndLocations_ShouldPersistMultipleLocationsInSameZone_AndEnforceCompositeTypeFk()
    {
        var polygon = _geometryFactory.CreatePolygon(new[]
        {
            new Coordinate(31.20, 29.95),
            new Coordinate(31.30, 29.95),
            new Coordinate(31.30, 30.05),
            new Coordinate(31.20, 30.05),
            new Coordinate(31.20, 29.95)
        });
        var zone = new Zone
        {
            Id = Guid.NewGuid(),
            Name = "Maadi",
            Slug = "maadi",
            ZoneType = ZoneType.ZONE,
            Boundary = _geometryFactory.CreateMultiPolygon(new[] { polygon })
        };

        var owner = new User
        {
            Id = Guid.NewGuid(),
            Email = "owner@finda.test",
            PasswordHash = "hashed",
            FullName = "Omar Owner"
        };

        var restaurantProvider = new Provider
        {
            Id = Guid.NewGuid(),
            OwnerUserId = owner.Id,
            ProviderType = ProviderType.RESTAURANT
        };

        var loc1 = new ProviderLocation
        {
            Id = Guid.NewGuid(),
            ProviderId = restaurantProvider.Id,
            ProviderType = ProviderType.RESTAURANT,
            ZoneId = zone.Id,
            BranchName = "Maadi Degla",
            AddressLine = "12 Road 231, Maadi",
            Location = _geometryFactory.CreatePoint(new Coordinate(31.27, 29.96))
        };

        var loc2 = new ProviderLocation
        {
            Id = Guid.NewGuid(),
            ProviderId = restaurantProvider.Id,
            ProviderType = ProviderType.RESTAURANT,
            ZoneId = zone.Id,
            BranchName = "Maadi Corniche",
            AddressLine = "45 Corniche El Nil, Maadi",
            Location = _geometryFactory.CreatePoint(new Coordinate(31.24, 29.97))
        };

        _db.Zones.Add(zone);
        _db.Users.Add(owner);
        _db.Providers.Add(restaurantProvider);
        _db.ProviderLocations.AddRange(loc1, loc2);
        await _db.SaveChangesAsync();

        var savedLocations = await _db.ProviderLocations
            .Where(l => l.ProviderId == restaurantProvider.Id && l.ZoneId == zone.Id)
            .ToListAsync();
        Assert.Equal(2, savedLocations.Count);

        // Attempting to insert a location with mismatched provider_type must fail composite FK
        var badLocation = new ProviderLocation
        {
            Id = Guid.NewGuid(),
            ProviderId = restaurantProvider.Id,
            ProviderType = ProviderType.HEALTHCARE,
            ZoneId = zone.Id,
            BranchName = "Invalid Type Branch",
            AddressLine = "Test",
            Location = _geometryFactory.CreatePoint(new Coordinate(31.25, 29.98))
        };
        _db.ProviderLocations.Add(badLocation);

        var ex = await Assert.ThrowsAsync<DbUpdateException>(() => _db.SaveChangesAsync());
        Assert.IsType<PostgresException>(ex.InnerException);
    }
}
