using Backend.Domain.Geography;
using Backend.Domain.Identity;
using Backend.Domain.Providers;
using Backend.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;

namespace Backend.UnitTests.Persistence;

public class CoreModelConfigurationTests
{
    private static AppDbContext CreateNpgsqlContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseNpgsql(
                "Host=localhost;Database=finda_test;Username=postgres;Password=postgres",
                npgsql => npgsql.UseNetTopologySuite())
            .Options;

        return new AppDbContext(options);
    }

    private static IModel GetDesignTimeModel(AppDbContext context) =>
        context.GetService<IDesignTimeModel>().Model;

    [Fact]
    public void Model_ShouldContainAll32ApprovedTables()
    {
        using var context = CreateNpgsqlContext();
        var tableNames = context.Model.GetEntityTypes()
            .Select(e => e.GetTableName())
            .OrderBy(n => n)
            .ToList();

        Assert.Equal(32, tableNames.Count);
        Assert.Contains("providers", tableNames);
        Assert.Contains("provider_locations", tableNames);
        Assert.Contains("zones", tableNames);
        Assert.Contains("general_providers", tableNames);
        Assert.Contains("restaurants", tableNames);
        Assert.Contains("healthcare_providers", tableNames);
        Assert.Contains("healthcare_appointments", tableNames);
        Assert.Contains("reviews", tableNames);
    }

    [Fact]
    public void Model_ShouldConfigurePostgresExtensions()
    {
        using var context = CreateNpgsqlContext();
        var extensions = GetDesignTimeModel(context).GetPostgresExtensions().Select(e => e.Name).ToList();

        Assert.Contains("postgis", extensions);
        Assert.Contains("btree_gist", extensions);
    }

    [Fact]
    public void Provider_ShouldHaveOwnerFk_AlternateKey_AndTypeCheckConstraint()
    {
        using var context = CreateNpgsqlContext();
        var entity = GetDesignTimeModel(context).FindEntityType(typeof(Provider))!;

        Assert.Equal("providers", entity.GetTableName());
        Assert.Equal("pk_providers", entity.FindPrimaryKey()!.GetName());

        var providerTypeProp = entity.FindProperty(nameof(Provider.ProviderType))!;
        Assert.Equal("provider_type", providerTypeProp.GetColumnName());
        Assert.Equal("varchar(30)", providerTypeProp.GetColumnType());

        var altKey = entity.GetKeys().SingleOrDefault(k => k.GetName() == "uq_providers_id_type");
        Assert.NotNull(altKey);

        var ownerFk = entity.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_providers_users_owner_user_id");
        Assert.Equal(DeleteBehavior.Restrict, ownerFk.DeleteBehavior);

        var check = entity.GetCheckConstraints().SingleOrDefault(c => c.Name == "ck_providers_provider_type");
        Assert.NotNull(check);
    }

    [Fact]
    public void ProviderLocation_ShouldHaveCompositeProviderFk_ZoneFk_AlternateKeys_AndGistIndex()
    {
        using var context = CreateNpgsqlContext();
        var entity = GetDesignTimeModel(context).FindEntityType(typeof(ProviderLocation))!;

        Assert.Equal("provider_locations", entity.GetTableName());
        Assert.Equal("pk_provider_locations", entity.FindPrimaryKey()!.GetName());

        var providerFk = entity.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_provider_locations_provider_type");
        Assert.Equal(DeleteBehavior.Cascade, providerFk.DeleteBehavior);
        Assert.Equal(new[] { "provider_id", "provider_type" }, providerFk.Properties.Select(p => p.GetColumnName()).ToArray());
        Assert.Equal("uq_providers_id_type", providerFk.PrincipalKey.GetName());

        var zoneFk = entity.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_provider_locations_zones_zone_id");
        Assert.Equal(DeleteBehavior.Restrict, zoneFk.DeleteBehavior);

        Assert.NotNull(entity.GetKeys().SingleOrDefault(k => k.GetName() == "uq_provider_locations_id_provider"));
        Assert.NotNull(entity.GetKeys().SingleOrDefault(k => k.GetName() == "uq_provider_locations_id_type"));

        var locationProp = entity.FindProperty(nameof(ProviderLocation.Location))!;
        Assert.Equal("geometry(Point, 4326)", locationProp.GetColumnType());

        var gistIndex = entity.GetIndexes().Single(i => i.GetDatabaseName() == "ix_provider_locations_location");
        Assert.Equal("gist", gistIndex.GetMethod());
    }

    [Fact]
    public void Zone_ShouldConfigureMultiPolygonSrid4326_GistIndex_AndValidBoundaryCheck()
    {
        using var context = CreateNpgsqlContext();
        var entity = GetDesignTimeModel(context).FindEntityType(typeof(Zone))!;

        Assert.Equal("zones", entity.GetTableName());
        Assert.Equal("geometry(MultiPolygon, 4326)", entity.FindProperty(nameof(Zone.Boundary))!.GetColumnType());
        Assert.Equal("geometry(Point, 4326)", entity.FindProperty(nameof(Zone.Centroid))!.GetColumnType());

        var gistIndex = entity.GetIndexes().Single(i => i.GetDatabaseName() == "ix_zones_boundary");
        Assert.Equal("gist", gistIndex.GetMethod());

        Assert.NotNull(entity.GetCheckConstraints().SingleOrDefault(c => c.Name == "ck_zones_boundary_valid"));
        Assert.NotNull(entity.GetCheckConstraints().SingleOrDefault(c => c.Name == "ck_zones_zone_type"));
    }

    [Fact]
    public void CustomerProfile_ShouldConfigureSelectedZoneFkWithSetNull()
    {
        using var context = CreateNpgsqlContext();
        var entity = context.Model.FindEntityType(typeof(CustomerProfile))!;

        Assert.Equal("customer_profiles", entity.GetTableName());
        var zoneFk = entity.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_customer_profiles_zones_selected_zone_id");
        Assert.Equal(DeleteBehavior.SetNull, zoneFk.DeleteBehavior);

        var userUnique = entity.GetIndexes().Single(i => i.GetDatabaseName() == "uq_customer_profiles_user_id");
        Assert.True(userUnique.IsUnique);
    }

    [Fact]
    public void IdentityTables_ShouldConfigureKeysAndDeleteBehaviors()
    {
        using var context = CreateNpgsqlContext();

        var user = context.Model.FindEntityType(typeof(User))!;
        Assert.True(user.GetIndexes().Single(i => i.GetDatabaseName() == "uq_users_email").IsUnique);

        var role = context.Model.FindEntityType(typeof(Role))!;
        Assert.True(role.GetIndexes().Single(i => i.GetDatabaseName() == "uq_roles_name").IsUnique);

        var userRole = context.Model.FindEntityType(typeof(UserRole))!;
        Assert.Equal("pk_user_roles", userRole.FindPrimaryKey()!.GetName());
        Assert.Equal(
            DeleteBehavior.Cascade,
            userRole.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_user_roles_users_user_id").DeleteBehavior);
        Assert.Equal(
            DeleteBehavior.Restrict,
            userRole.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_user_roles_roles_role_id").DeleteBehavior);

        var refreshToken = context.Model.FindEntityType(typeof(RefreshToken))!;
        Assert.True(refreshToken.GetIndexes().Single(i => i.GetDatabaseName() == "uq_refresh_tokens_token_hash").IsUnique);
    }

    [Fact]
    public void IntegrityCompositeForeignKeys_ShouldEnforceServiceCategoryAndCustomerOwnership()
    {
        using var context = CreateNpgsqlContext();
        var model = GetDesignTimeModel(context);

        var serviceRequest = model.FindEntityType(typeof(Backend.Domain.Marketplace.ServiceRequest))!;
        var gpFk = serviceRequest.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_service_requests_general_provider_service");
        Assert.Equal(new[] { "general_provider_id", "service_id" }, gpFk.Properties.Select(p => p.GetColumnName()).ToArray());

        var menuItem = model.FindEntityType(typeof(Backend.Domain.Food.MenuItem))!;
        var catFk = menuItem.GetForeignKeys().Single(fk => fk.GetConstraintName() == "fk_menu_items_menu_category_restaurant");
        Assert.Equal(new[] { "menu_category_id", "restaurant_id" }, catFk.Properties.Select(p => p.GetColumnName()).ToArray());

        var review = model.FindEntityType(typeof(Backend.Domain.Reviews.Review))!;
        Assert.Contains(review.GetForeignKeys(), fk => fk.GetConstraintName() == "fk_reviews_service_request_customer");
        Assert.Contains(review.GetForeignKeys(), fk => fk.GetConstraintName() == "fk_reviews_food_order_customer");
        Assert.Contains(review.GetForeignKeys(), fk => fk.GetConstraintName() == "fk_reviews_healthcare_appointment_customer");

        var restSettings = model.FindEntityType(typeof(Backend.Domain.Food.RestaurantLocationSettings))!;
        Assert.Single(restSettings.GetIndexes().Where(i => i.IsUnique));

        var healthSettings = model.FindEntityType(typeof(Backend.Domain.Healthcare.HealthcareLocationSettings))!;
        Assert.Single(healthSettings.GetIndexes().Where(i => i.IsUnique));
    }
}
