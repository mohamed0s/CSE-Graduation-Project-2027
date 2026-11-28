using System;
using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

#nullable disable

namespace Backend.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:btree_gist", ",,")
                .Annotation("Npgsql:PostgresExtension:postgis", ",,");

            migrationBuilder.CreateTable(
                name: "medical_specialties",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    name = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    slug = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_medical_specialties", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "roles",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    name = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    description = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_roles", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "service_categories",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    name = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    slug = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_service_categories", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "users",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    email = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false),
                    password_hash = table.Column<string>(type: "text", nullable: false),
                    full_name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    phone_number = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: true),
                    status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, defaultValue: "ACTIVE"),
                    deleted_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_users", x => x.id);
                    table.CheckConstraint("ck_users_status", "status IN ('ACTIVE','SUSPENDED','DELETED')");
                });

            migrationBuilder.CreateTable(
                name: "zones",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    parent_zone_id = table.Column<Guid>(type: "uuid", nullable: true),
                    name = table.Column<string>(type: "varchar(120)", maxLength: 120, nullable: false),
                    slug = table.Column<string>(type: "varchar(120)", maxLength: 120, nullable: false),
                    zone_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "ZONE"),
                    boundary = table.Column<MultiPolygon>(type: "geometry(MultiPolygon, 4326)", nullable: false),
                    centroid = table.Column<Point>(type: "geometry(Point, 4326)", nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_zones", x => x.id);
                    table.CheckConstraint("ck_zones_boundary_valid", "ST_IsValid(boundary)");
                    table.CheckConstraint("ck_zones_zone_type", "zone_type IN ('CITY','ZONE','NEIGHBORHOOD')");
                    table.ForeignKey(
                        name: "fk_zones_zones_parent_zone_id",
                        column: x => x.parent_zone_id,
                        principalTable: "zones",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "services",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    category_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    base_price = table.Column<decimal>(type: "numeric(12,2)", nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_services", x => x.id);
                    table.CheckConstraint("ck_services_base_price", "base_price IS NULL OR base_price >= 0");
                    table.ForeignKey(
                        name: "fk_services_service_categories_category_id",
                        column: x => x.category_id,
                        principalTable: "service_categories",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "notification_preferences",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    in_app_enabled = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    push_enabled = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    email_enabled = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_notification_preferences", x => x.id);
                    table.ForeignKey(
                        name: "fk_notification_preferences_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "notifications",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    type = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false),
                    title = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    body = table.Column<string>(type: "text", nullable: false),
                    reference_type = table.Column<string>(type: "varchar(40)", maxLength: 40, nullable: true),
                    reference_id = table.Column<Guid>(type: "uuid", nullable: true),
                    is_read = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    read_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_notifications", x => x.id);
                    table.ForeignKey(
                        name: "fk_notifications_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "providers",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    owner_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_providers", x => x.id);
                    table.UniqueConstraint("uq_providers_id_type", x => new { x.id, x.provider_type });
                    table.CheckConstraint("ck_providers_provider_type", "provider_type IN ('GENERAL','RESTAURANT','HEALTHCARE')");
                    table.ForeignKey(
                        name: "fk_providers_users_owner_user_id",
                        column: x => x.owner_user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "refresh_tokens",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    token_hash = table.Column<string>(type: "varchar(128)", maxLength: 128, nullable: false),
                    expires_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false),
                    revoked_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    replaced_by_token_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_refresh_tokens", x => x.id);
                    table.ForeignKey(
                        name: "fk_refresh_tokens_refresh_tokens_replaced_by_token_id",
                        column: x => x.replaced_by_token_id,
                        principalTable: "refresh_tokens",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_refresh_tokens_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_roles",
                columns: table => new
                {
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    role_id = table.Column<Guid>(type: "uuid", nullable: false),
                    assigned_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_user_roles", x => new { x.user_id, x.role_id });
                    table.ForeignKey(
                        name: "fk_user_roles_roles_role_id",
                        column: x => x.role_id,
                        principalTable: "roles",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_user_roles_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "customer_profiles",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    selected_zone_id = table.Column<Guid>(type: "uuid", nullable: true),
                    default_address = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_customer_profiles", x => x.id);
                    table.ForeignKey(
                        name: "fk_customer_profiles_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_customer_profiles_zones_selected_zone_id",
                        column: x => x.selected_zone_id,
                        principalTable: "zones",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "general_providers",
                columns: table => new
                {
                    provider_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "GENERAL"),
                    service_id = table.Column<Guid>(type: "uuid", nullable: false),
                    display_name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    bio = table.Column<string>(type: "text", nullable: true),
                    years_experience = table.Column<short>(type: "smallint", nullable: true),
                    average_rating = table.Column<decimal>(type: "numeric(3,2)", nullable: false, defaultValue: 0.00m),
                    total_reviews = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_general_providers", x => x.provider_id);
                    table.UniqueConstraint("uq_general_providers_provider_service", x => new { x.provider_id, x.service_id });
                    table.CheckConstraint("ck_general_providers_average_rating", "average_rating >= 0 AND average_rating <= 5");
                    table.CheckConstraint("ck_general_providers_type", "provider_type = 'GENERAL'");
                    table.CheckConstraint("ck_general_providers_years_experience", "years_experience IS NULL OR years_experience >= 0");
                    table.ForeignKey(
                        name: "fk_general_providers_provider_type",
                        columns: x => new { x.provider_id, x.provider_type },
                        principalTable: "providers",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_general_providers_services_service_id",
                        column: x => x.service_id,
                        principalTable: "services",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "healthcare_providers",
                columns: table => new
                {
                    provider_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "HEALTHCARE"),
                    specialty_id = table.Column<Guid>(type: "uuid", nullable: false),
                    full_name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    title = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: true),
                    bio = table.Column<string>(type: "text", nullable: true),
                    average_rating = table.Column<decimal>(type: "numeric(3,2)", nullable: false, defaultValue: 0.00m),
                    total_reviews = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_healthcare_providers", x => x.provider_id);
                    table.CheckConstraint("ck_healthcare_providers_average_rating", "average_rating >= 0 AND average_rating <= 5");
                    table.CheckConstraint("ck_healthcare_providers_type", "provider_type = 'HEALTHCARE'");
                    table.ForeignKey(
                        name: "fk_healthcare_providers_medical_specialties_specialty_id",
                        column: x => x.specialty_id,
                        principalTable: "medical_specialties",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_healthcare_providers_provider_type",
                        columns: x => new { x.provider_id, x.provider_type },
                        principalTable: "providers",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "provider_locations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    provider_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false),
                    zone_id = table.Column<Guid>(type: "uuid", nullable: false),
                    branch_name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    address_line = table.Column<string>(type: "text", nullable: false),
                    location = table.Column<Point>(type: "geometry(Point, 4326)", nullable: false),
                    phone_number = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_provider_locations", x => x.id);
                    table.UniqueConstraint("uq_provider_locations_id_provider", x => new { x.id, x.provider_id });
                    table.UniqueConstraint("uq_provider_locations_id_type", x => new { x.id, x.provider_type });
                    table.CheckConstraint("ck_provider_locations_type", "provider_type IN ('GENERAL','RESTAURANT','HEALTHCARE')");
                    table.ForeignKey(
                        name: "fk_provider_locations_provider_type",
                        columns: x => new { x.provider_id, x.provider_type },
                        principalTable: "providers",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_provider_locations_zones_zone_id",
                        column: x => x.zone_id,
                        principalTable: "zones",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "restaurants",
                columns: table => new
                {
                    provider_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "RESTAURANT"),
                    name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    cuisine_type = table.Column<string>(type: "varchar(80)", maxLength: 80, nullable: true),
                    operating_mode = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, defaultValue: "MENU_ONLY"),
                    average_rating = table.Column<decimal>(type: "numeric(3,2)", nullable: false, defaultValue: 0.00m),
                    total_reviews = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_restaurants", x => x.provider_id);
                    table.CheckConstraint("ck_restaurants_average_rating", "average_rating >= 0 AND average_rating <= 5");
                    table.CheckConstraint("ck_restaurants_operating_mode", "operating_mode IN ('MENU_ONLY','ORDER_ENABLED')");
                    table.CheckConstraint("ck_restaurants_type", "provider_type = 'RESTAURANT'");
                    table.ForeignKey(
                        name: "fk_restaurants_provider_type",
                        columns: x => new { x.provider_id, x.provider_type },
                        principalTable: "providers",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "healthcare_appointments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    customer_id = table.Column<Guid>(type: "uuid", nullable: false),
                    healthcare_provider_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    start_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false),
                    end_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false),
                    duration_minutes = table.Column<int>(type: "integer", nullable: false),
                    consultation_fee_snapshot = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, defaultValue: "PENDING"),
                    patient_notes = table.Column<string>(type: "text", nullable: true),
                    rejection_reason = table.Column<string>(type: "text", nullable: true),
                    cancellation_reason = table.Column<string>(type: "text", nullable: true),
                    cancelled_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    cancelled_by_user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    rescheduled_from_appointment_id = table.Column<Guid>(type: "uuid", nullable: true),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_healthcare_appointments", x => x.id);
                    table.UniqueConstraint("uq_healthcare_appointments_id_customer", x => new { x.id, x.customer_id });
                    table.CheckConstraint("ck_healthcare_appointments_fee", "consultation_fee_snapshot >= 0");
                    table.CheckConstraint("ck_healthcare_appointments_range", "end_at > start_at AND duration_minutes > 0");
                    table.CheckConstraint("ck_healthcare_appointments_status", "status IN ('PENDING','CONFIRMED','COMPLETED','REJECTED','CANCELLED','NO_SHOW')");
                    table.ForeignKey(
                        name: "fk_healthcare_appointments_healthcare_providers_id",
                        column: x => x.healthcare_provider_id,
                        principalTable: "healthcare_providers",
                        principalColumn: "provider_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_healthcare_appointments_provider_location_owner",
                        columns: x => new { x.provider_location_id, x.healthcare_provider_id },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_healthcare_appointments_rescheduled_from_id",
                        column: x => x.rescheduled_from_appointment_id,
                        principalTable: "healthcare_appointments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_healthcare_appointments_users_cancelled_by_user_id",
                        column: x => x.cancelled_by_user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_healthcare_appointments_users_customer_id",
                        column: x => x.customer_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "healthcare_location_settings",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "HEALTHCARE"),
                    consultation_fee = table.Column<decimal>(type: "numeric(12,2)", nullable: false, defaultValue: 0.00m),
                    slot_duration_minutes = table.Column<int>(type: "integer", nullable: false, defaultValue: 30),
                    requires_approval = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    timezone = table.Column<string>(type: "varchar(64)", maxLength: 64, nullable: false, defaultValue: "Africa/Cairo"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_healthcare_location_settings", x => x.id);
                    table.CheckConstraint("ck_healthcare_location_settings_fee", "consultation_fee >= 0");
                    table.CheckConstraint("ck_healthcare_location_settings_slot_duration", "slot_duration_minutes >= 5 AND slot_duration_minutes <= 240");
                    table.CheckConstraint("ck_healthcare_location_settings_type", "provider_type = 'HEALTHCARE'");
                    table.ForeignKey(
                        name: "fk_healthcare_location_settings_provider_location_type",
                        columns: x => new { x.provider_location_id, x.provider_type },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "provider_schedules",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "HEALTHCARE"),
                    day_of_week = table.Column<short>(type: "smallint", nullable: false),
                    start_time = table.Column<TimeOnly>(type: "time", nullable: false),
                    end_time = table.Column<TimeOnly>(type: "time", nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_provider_schedules", x => x.id);
                    table.CheckConstraint("ck_provider_schedules_day_of_week", "day_of_week >= 0 AND day_of_week <= 6");
                    table.CheckConstraint("ck_provider_schedules_times", "start_time < end_time");
                    table.CheckConstraint("ck_provider_schedules_type", "provider_type = 'HEALTHCARE'");
                    table.ForeignKey(
                        name: "fk_provider_schedules_provider_location_type",
                        columns: x => new { x.provider_location_id, x.provider_type },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "restaurant_location_settings",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "RESTAURANT"),
                    is_accepting_orders = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    delivery_fee = table.Column<decimal>(type: "numeric(12,2)", nullable: false, defaultValue: 0.00m),
                    estimated_delivery_minutes = table.Column<int>(type: "integer", nullable: true),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_restaurant_location_settings", x => x.id);
                    table.CheckConstraint("ck_restaurant_location_settings_delivery_fee", "delivery_fee >= 0");
                    table.CheckConstraint("ck_restaurant_location_settings_type", "provider_type = 'RESTAURANT'");
                    table.ForeignKey(
                        name: "fk_restaurant_location_settings_provider_location_type",
                        columns: x => new { x.provider_location_id, x.provider_type },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "restaurant_operating_hours",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "RESTAURANT"),
                    day_of_week = table.Column<short>(type: "smallint", nullable: false),
                    open_time = table.Column<TimeOnly>(type: "time", nullable: true),
                    close_time = table.Column<TimeOnly>(type: "time", nullable: true),
                    is_closed = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_restaurant_operating_hours", x => x.id);
                    table.CheckConstraint("ck_restaurant_operating_hours_day_of_week", "day_of_week >= 0 AND day_of_week <= 6");
                    table.CheckConstraint("ck_restaurant_operating_hours_times", "is_closed = true OR (open_time IS NOT NULL AND close_time IS NOT NULL AND open_time < close_time)");
                    table.CheckConstraint("ck_restaurant_operating_hours_type", "provider_type = 'RESTAURANT'");
                    table.ForeignKey(
                        name: "fk_restaurant_operating_hours_provider_location_type",
                        columns: x => new { x.provider_location_id, x.provider_type },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "schedule_exceptions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_type = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "HEALTHCARE"),
                    exception_date = table.Column<DateOnly>(type: "date", nullable: false),
                    is_day_off = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    start_time = table.Column<TimeOnly>(type: "time", nullable: true),
                    end_time = table.Column<TimeOnly>(type: "time", nullable: true),
                    reason = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_schedule_exceptions", x => x.id);
                    table.CheckConstraint("ck_schedule_exceptions_times", "is_day_off = true OR (start_time IS NOT NULL AND end_time IS NOT NULL AND start_time < end_time)");
                    table.CheckConstraint("ck_schedule_exceptions_type", "provider_type = 'HEALTHCARE'");
                    table.ForeignKey(
                        name: "fk_schedule_exceptions_provider_location_type",
                        columns: x => new { x.provider_location_id, x.provider_type },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_type" },
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "service_requests",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    customer_id = table.Column<Guid>(type: "uuid", nullable: false),
                    general_provider_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    service_id = table.Column<Guid>(type: "uuid", nullable: false),
                    status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, defaultValue: "PENDING"),
                    description = table.Column<string>(type: "text", nullable: false),
                    service_address = table.Column<string>(type: "text", nullable: false),
                    preferred_date = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    agreed_price = table.Column<decimal>(type: "numeric(12,2)", nullable: true),
                    rejection_reason = table.Column<string>(type: "text", nullable: true),
                    cancellation_reason = table.Column<string>(type: "text", nullable: true),
                    cancelled_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    cancelled_by_user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    completed_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_service_requests", x => x.id);
                    table.UniqueConstraint("uq_service_requests_id_customer", x => new { x.id, x.customer_id });
                    table.CheckConstraint("ck_service_requests_agreed_price", "agreed_price IS NULL OR agreed_price >= 0");
                    table.CheckConstraint("ck_service_requests_status", "status IN ('PENDING','ACCEPTED','IN_PROGRESS','COMPLETED','REJECTED','CANCELLED')");
                    table.ForeignKey(
                        name: "fk_service_requests_general_provider_service",
                        columns: x => new { x.general_provider_id, x.service_id },
                        principalTable: "general_providers",
                        principalColumns: new[] { "provider_id", "service_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_service_requests_provider_location_owner",
                        columns: x => new { x.provider_location_id, x.general_provider_id },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_service_requests_services_service_id",
                        column: x => x.service_id,
                        principalTable: "services",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_service_requests_users_cancelled_by_user_id",
                        column: x => x.cancelled_by_user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "fk_service_requests_users_customer_id",
                        column: x => x.customer_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "food_orders",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    order_number = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false),
                    customer_id = table.Column<Guid>(type: "uuid", nullable: false),
                    restaurant_id = table.Column<Guid>(type: "uuid", nullable: false),
                    provider_location_id = table.Column<Guid>(type: "uuid", nullable: false),
                    status = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "PENDING"),
                    fulfillment_type = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, defaultValue: "DELIVERY"),
                    payment_method = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false, defaultValue: "CASH_ON_DELIVERY"),
                    payment_status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, defaultValue: "PENDING"),
                    subtotal = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    delivery_fee = table.Column<decimal>(type: "numeric(12,2)", nullable: false, defaultValue: 0.00m),
                    total_amount = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    customer_notes = table.Column<string>(type: "text", nullable: true),
                    rejection_reason = table.Column<string>(type: "text", nullable: true),
                    cancellation_reason = table.Column<string>(type: "text", nullable: true),
                    cancelled_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: true),
                    xmin = table.Column<uint>(type: "xid", rowVersion: true, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_food_orders", x => x.id);
                    table.UniqueConstraint("uq_food_orders_id_customer", x => new { x.id, x.customer_id });
                    table.CheckConstraint("ck_food_orders_fulfillment_type", "fulfillment_type IN ('DELIVERY','PICKUP')");
                    table.CheckConstraint("ck_food_orders_status", "status IN ('PENDING','ACCEPTED','PREPARING','OUT_FOR_DELIVERY','READY_FOR_PICKUP','DELIVERED','COMPLETED','REJECTED','CANCELLED')");
                    table.CheckConstraint("ck_food_orders_totals", "subtotal >= 0 AND delivery_fee >= 0 AND total_amount = subtotal + delivery_fee");
                    table.ForeignKey(
                        name: "fk_food_orders_provider_location_owner",
                        columns: x => new { x.provider_location_id, x.restaurant_id },
                        principalTable: "provider_locations",
                        principalColumns: new[] { "id", "provider_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_food_orders_restaurants_restaurant_id",
                        column: x => x.restaurant_id,
                        principalTable: "restaurants",
                        principalColumn: "provider_id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_food_orders_users_customer_id",
                        column: x => x.customer_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "menu_categories",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    restaurant_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    display_order = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_menu_categories", x => x.id);
                    table.UniqueConstraint("uq_menu_categories_id_restaurant", x => new { x.id, x.restaurant_id });
                    table.ForeignKey(
                        name: "fk_menu_categories_restaurants_restaurant_id",
                        column: x => x.restaurant_id,
                        principalTable: "restaurants",
                        principalColumn: "provider_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "appointment_status_history",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    appointment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    from_status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: true),
                    to_status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false),
                    changed_by_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    note = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_appointment_status_history", x => x.id);
                    table.ForeignKey(
                        name: "fk_appointment_status_history_appointments_appointment_id",
                        column: x => x.appointment_id,
                        principalTable: "healthcare_appointments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_appointment_status_history_users_changed_by_user_id",
                        column: x => x.changed_by_user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "service_request_status_history",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    service_request_id = table.Column<Guid>(type: "uuid", nullable: false),
                    from_status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: true),
                    to_status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false),
                    changed_by_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    note = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_service_request_status_history", x => x.id);
                    table.ForeignKey(
                        name: "fk_service_request_status_history_service_requests_id",
                        column: x => x.service_request_id,
                        principalTable: "service_requests",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_service_request_status_history_users_changed_by_user_id",
                        column: x => x.changed_by_user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "food_order_delivery_info",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    food_order_id = table.Column<Guid>(type: "uuid", nullable: false),
                    recipient_name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    recipient_phone = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false),
                    address_line = table.Column<string>(type: "text", nullable: false),
                    city = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: false),
                    delivery_instructions = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_food_order_delivery_info", x => x.id);
                    table.ForeignKey(
                        name: "fk_food_order_delivery_info_food_orders_food_order_id",
                        column: x => x.food_order_id,
                        principalTable: "food_orders",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "food_order_status_history",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    food_order_id = table.Column<Guid>(type: "uuid", nullable: false),
                    from_status = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: true),
                    to_status = table.Column<string>(type: "varchar(30)", maxLength: 30, nullable: false),
                    changed_by_user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    note = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_food_order_status_history", x => x.id);
                    table.ForeignKey(
                        name: "fk_food_order_status_history_food_orders_food_order_id",
                        column: x => x.food_order_id,
                        principalTable: "food_orders",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_food_order_status_history_users_changed_by_user_id",
                        column: x => x.changed_by_user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "reviews",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    customer_id = table.Column<Guid>(type: "uuid", nullable: false),
                    target_domain = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false),
                    service_request_id = table.Column<Guid>(type: "uuid", nullable: true),
                    food_order_id = table.Column<Guid>(type: "uuid", nullable: true),
                    healthcare_appointment_id = table.Column<Guid>(type: "uuid", nullable: true),
                    rating = table.Column<short>(type: "smallint", nullable: false),
                    comment = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_reviews", x => x.id);
                    table.CheckConstraint("ck_reviews_rating", "rating >= 1 AND rating <= 5");
                    table.CheckConstraint("ck_reviews_single_target", "(target_domain = 'GENERAL_SERVICE' AND service_request_id IS NOT NULL AND food_order_id IS NULL AND healthcare_appointment_id IS NULL) OR (target_domain = 'FOOD_ORDER' AND service_request_id IS NULL AND food_order_id IS NOT NULL AND healthcare_appointment_id IS NULL) OR (target_domain = 'HEALTHCARE' AND service_request_id IS NULL AND food_order_id IS NULL AND healthcare_appointment_id IS NOT NULL)");
                    table.CheckConstraint("ck_reviews_target_domain", "target_domain IN ('GENERAL_SERVICE','FOOD_ORDER','HEALTHCARE')");
                    table.ForeignKey(
                        name: "fk_reviews_food_order_customer",
                        columns: x => new { x.food_order_id, x.customer_id },
                        principalTable: "food_orders",
                        principalColumns: new[] { "id", "customer_id" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_reviews_healthcare_appointment_customer",
                        columns: x => new { x.healthcare_appointment_id, x.customer_id },
                        principalTable: "healthcare_appointments",
                        principalColumns: new[] { "id", "customer_id" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_reviews_service_request_customer",
                        columns: x => new { x.service_request_id, x.customer_id },
                        principalTable: "service_requests",
                        principalColumns: new[] { "id", "customer_id" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_reviews_users_customer_id",
                        column: x => x.customer_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "menu_items",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    restaurant_id = table.Column<Guid>(type: "uuid", nullable: false),
                    menu_category_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    description = table.Column<string>(type: "text", nullable: true),
                    price = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    image_url = table.Column<string>(type: "text", nullable: true),
                    is_available = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()"),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamptz", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_menu_items", x => x.id);
                    table.CheckConstraint("ck_menu_items_price", "price >= 0");
                    table.ForeignKey(
                        name: "fk_menu_items_menu_category_restaurant",
                        columns: x => new { x.menu_category_id, x.restaurant_id },
                        principalTable: "menu_categories",
                        principalColumns: new[] { "id", "restaurant_id" },
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_menu_items_restaurants_restaurant_id",
                        column: x => x.restaurant_id,
                        principalTable: "restaurants",
                        principalColumn: "provider_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "food_order_items",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    food_order_id = table.Column<Guid>(type: "uuid", nullable: false),
                    menu_item_id = table.Column<Guid>(type: "uuid", nullable: true),
                    item_name_snapshot = table.Column<string>(type: "varchar(150)", maxLength: 150, nullable: false),
                    unit_price_snapshot = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    quantity = table.Column<int>(type: "integer", nullable: false),
                    line_total = table.Column<decimal>(type: "numeric(12,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_food_order_items", x => x.id);
                    table.CheckConstraint("ck_food_order_items_quantity", "quantity > 0");
                    table.CheckConstraint("ck_food_order_items_totals", "unit_price_snapshot >= 0 AND line_total = unit_price_snapshot * quantity");
                    table.ForeignKey(
                        name: "fk_food_order_items_food_orders_food_order_id",
                        column: x => x.food_order_id,
                        principalTable: "food_orders",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_food_order_items_menu_items_menu_item_id",
                        column: x => x.menu_item_id,
                        principalTable: "menu_items",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "ix_appointment_status_history_appointment_id",
                table: "appointment_status_history",
                column: "appointment_id");

            migrationBuilder.CreateIndex(
                name: "IX_appointment_status_history_changed_by_user_id",
                table: "appointment_status_history",
                column: "changed_by_user_id");

            migrationBuilder.CreateIndex(
                name: "ix_customer_profiles_selected_zone_id",
                table: "customer_profiles",
                column: "selected_zone_id");

            migrationBuilder.CreateIndex(
                name: "uq_customer_profiles_user_id",
                table: "customer_profiles",
                column: "user_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_food_order_delivery_info_food_order_id",
                table: "food_order_delivery_info",
                column: "food_order_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_food_order_items_food_order_id",
                table: "food_order_items",
                column: "food_order_id");

            migrationBuilder.CreateIndex(
                name: "IX_food_order_items_menu_item_id",
                table: "food_order_items",
                column: "menu_item_id");

            migrationBuilder.CreateIndex(
                name: "IX_food_order_status_history_changed_by_user_id",
                table: "food_order_status_history",
                column: "changed_by_user_id");

            migrationBuilder.CreateIndex(
                name: "ix_food_order_status_history_food_order_id",
                table: "food_order_status_history",
                column: "food_order_id");

            migrationBuilder.CreateIndex(
                name: "ix_food_orders_customer_id_created_at",
                table: "food_orders",
                columns: new[] { "customer_id", "created_at" });

            migrationBuilder.CreateIndex(
                name: "IX_food_orders_provider_location_id_restaurant_id",
                table: "food_orders",
                columns: new[] { "provider_location_id", "restaurant_id" });

            migrationBuilder.CreateIndex(
                name: "ix_food_orders_provider_location_status_created_at",
                table: "food_orders",
                columns: new[] { "provider_location_id", "status", "created_at" });

            migrationBuilder.CreateIndex(
                name: "IX_food_orders_restaurant_id",
                table: "food_orders",
                column: "restaurant_id");

            migrationBuilder.CreateIndex(
                name: "uq_food_orders_order_number",
                table: "food_orders",
                column: "order_number",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_general_providers_provider_id_provider_type",
                table: "general_providers",
                columns: new[] { "provider_id", "provider_type" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_general_providers_service_id_is_active",
                table: "general_providers",
                columns: new[] { "service_id", "is_active" });

            migrationBuilder.CreateIndex(
                name: "IX_healthcare_appointments_cancelled_by_user_id",
                table: "healthcare_appointments",
                column: "cancelled_by_user_id");

            migrationBuilder.CreateIndex(
                name: "ix_healthcare_appointments_customer_id_start_at",
                table: "healthcare_appointments",
                columns: new[] { "customer_id", "start_at" });

            migrationBuilder.CreateIndex(
                name: "IX_healthcare_appointments_healthcare_provider_id",
                table: "healthcare_appointments",
                column: "healthcare_provider_id");

            migrationBuilder.CreateIndex(
                name: "IX_healthcare_appointments_provider_location_id_healthcare_pro~",
                table: "healthcare_appointments",
                columns: new[] { "provider_location_id", "healthcare_provider_id" });

            migrationBuilder.CreateIndex(
                name: "ix_healthcare_appointments_provider_location_id_start_at",
                table: "healthcare_appointments",
                columns: new[] { "provider_location_id", "start_at" });

            migrationBuilder.CreateIndex(
                name: "IX_healthcare_appointments_rescheduled_from_appointment_id",
                table: "healthcare_appointments",
                column: "rescheduled_from_appointment_id");

            migrationBuilder.CreateIndex(
                name: "IX_healthcare_location_settings_provider_location_id_provider_~",
                table: "healthcare_location_settings",
                columns: new[] { "provider_location_id", "provider_type" });

            migrationBuilder.CreateIndex(
                name: "uq_healthcare_location_settings_provider_location_id",
                table: "healthcare_location_settings",
                column: "provider_location_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_healthcare_providers_provider_id_provider_type",
                table: "healthcare_providers",
                columns: new[] { "provider_id", "provider_type" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_healthcare_providers_specialty_id_is_active",
                table: "healthcare_providers",
                columns: new[] { "specialty_id", "is_active" });

            migrationBuilder.CreateIndex(
                name: "uq_medical_specialties_name",
                table: "medical_specialties",
                column: "name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_medical_specialties_slug",
                table: "medical_specialties",
                column: "slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_menu_categories_restaurant_id_display_order",
                table: "menu_categories",
                columns: new[] { "restaurant_id", "display_order" });

            migrationBuilder.CreateIndex(
                name: "IX_menu_items_menu_category_id_restaurant_id",
                table: "menu_items",
                columns: new[] { "menu_category_id", "restaurant_id" });

            migrationBuilder.CreateIndex(
                name: "ix_menu_items_restaurant_category_available",
                table: "menu_items",
                columns: new[] { "restaurant_id", "menu_category_id", "is_available" });

            migrationBuilder.CreateIndex(
                name: "uq_notification_preferences_user_id",
                table: "notification_preferences",
                column: "user_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_notifications_user_id_is_read_created_at",
                table: "notifications",
                columns: new[] { "user_id", "is_read", "created_at" });

            migrationBuilder.CreateIndex(
                name: "ix_provider_locations_location",
                table: "provider_locations",
                column: "location")
                .Annotation("Npgsql:IndexMethod", "gist");

            migrationBuilder.CreateIndex(
                name: "ix_provider_locations_provider_id_is_active",
                table: "provider_locations",
                columns: new[] { "provider_id", "is_active" });

            migrationBuilder.CreateIndex(
                name: "IX_provider_locations_provider_id_provider_type",
                table: "provider_locations",
                columns: new[] { "provider_id", "provider_type" });

            migrationBuilder.CreateIndex(
                name: "ix_provider_locations_zone_id_provider_type_is_active",
                table: "provider_locations",
                columns: new[] { "zone_id", "provider_type", "is_active" });

            migrationBuilder.CreateIndex(
                name: "ix_provider_schedules_location_day_active",
                table: "provider_schedules",
                columns: new[] { "provider_location_id", "day_of_week", "is_active" });

            migrationBuilder.CreateIndex(
                name: "IX_provider_schedules_provider_location_id_provider_type",
                table: "provider_schedules",
                columns: new[] { "provider_location_id", "provider_type" });

            migrationBuilder.CreateIndex(
                name: "ix_providers_owner_user_id",
                table: "providers",
                column: "owner_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_refresh_tokens_replaced_by_token_id",
                table: "refresh_tokens",
                column: "replaced_by_token_id");

            migrationBuilder.CreateIndex(
                name: "ix_refresh_tokens_user_id",
                table: "refresh_tokens",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "uq_refresh_tokens_token_hash",
                table: "refresh_tokens",
                column: "token_hash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_restaurant_location_settings_provider_location_id_provider_~",
                table: "restaurant_location_settings",
                columns: new[] { "provider_location_id", "provider_type" });

            migrationBuilder.CreateIndex(
                name: "uq_restaurant_location_settings_provider_location_id",
                table: "restaurant_location_settings",
                column: "provider_location_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_restaurant_operating_hours_provider_location_id_provider_ty~",
                table: "restaurant_operating_hours",
                columns: new[] { "provider_location_id", "provider_type" });

            migrationBuilder.CreateIndex(
                name: "uq_restaurant_operating_hours_location_day",
                table: "restaurant_operating_hours",
                columns: new[] { "provider_location_id", "day_of_week" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_restaurants_operating_mode_is_active",
                table: "restaurants",
                columns: new[] { "operating_mode", "is_active" });

            migrationBuilder.CreateIndex(
                name: "IX_restaurants_provider_id_provider_type",
                table: "restaurants",
                columns: new[] { "provider_id", "provider_type" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reviews_customer_id",
                table: "reviews",
                column: "customer_id");

            migrationBuilder.CreateIndex(
                name: "IX_reviews_food_order_id_customer_id",
                table: "reviews",
                columns: new[] { "food_order_id", "customer_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reviews_healthcare_appointment_id_customer_id",
                table: "reviews",
                columns: new[] { "healthcare_appointment_id", "customer_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reviews_service_request_id_customer_id",
                table: "reviews",
                columns: new[] { "service_request_id", "customer_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_reviews_food_order_id",
                table: "reviews",
                column: "food_order_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_reviews_healthcare_appointment_id",
                table: "reviews",
                column: "healthcare_appointment_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_reviews_service_request_id",
                table: "reviews",
                column: "service_request_id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_roles_name",
                table: "roles",
                column: "name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_schedule_exceptions_location_date",
                table: "schedule_exceptions",
                columns: new[] { "provider_location_id", "exception_date" });

            migrationBuilder.CreateIndex(
                name: "IX_schedule_exceptions_provider_location_id_provider_type",
                table: "schedule_exceptions",
                columns: new[] { "provider_location_id", "provider_type" });

            migrationBuilder.CreateIndex(
                name: "uq_service_categories_name",
                table: "service_categories",
                column: "name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "uq_service_categories_slug",
                table: "service_categories",
                column: "slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_service_request_status_history_changed_by_user_id",
                table: "service_request_status_history",
                column: "changed_by_user_id");

            migrationBuilder.CreateIndex(
                name: "ix_service_request_status_history_service_request_id",
                table: "service_request_status_history",
                column: "service_request_id");

            migrationBuilder.CreateIndex(
                name: "IX_service_requests_cancelled_by_user_id",
                table: "service_requests",
                column: "cancelled_by_user_id");

            migrationBuilder.CreateIndex(
                name: "ix_service_requests_customer_id_created_at",
                table: "service_requests",
                columns: new[] { "customer_id", "created_at" });

            migrationBuilder.CreateIndex(
                name: "IX_service_requests_general_provider_id_service_id",
                table: "service_requests",
                columns: new[] { "general_provider_id", "service_id" });

            migrationBuilder.CreateIndex(
                name: "IX_service_requests_provider_location_id_general_provider_id",
                table: "service_requests",
                columns: new[] { "provider_location_id", "general_provider_id" });

            migrationBuilder.CreateIndex(
                name: "ix_service_requests_provider_location_id_status_created_at",
                table: "service_requests",
                columns: new[] { "provider_location_id", "status", "created_at" });

            migrationBuilder.CreateIndex(
                name: "IX_service_requests_service_id",
                table: "service_requests",
                column: "service_id");

            migrationBuilder.CreateIndex(
                name: "ix_services_category_id",
                table: "services",
                column: "category_id");

            migrationBuilder.CreateIndex(
                name: "IX_user_roles_role_id",
                table: "user_roles",
                column: "role_id");

            migrationBuilder.CreateIndex(
                name: "uq_users_email",
                table: "users",
                column: "email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_zones_boundary",
                table: "zones",
                column: "boundary")
                .Annotation("Npgsql:IndexMethod", "gist");

            migrationBuilder.CreateIndex(
                name: "ix_zones_parent_zone_id_is_active",
                table: "zones",
                columns: new[] { "parent_zone_id", "is_active" });

            migrationBuilder.CreateIndex(
                name: "uq_zones_slug",
                table: "zones",
                column: "slug",
                unique: true);

            migrationBuilder.Sql(
                "CREATE INDEX ix_provider_locations_location_geog ON provider_locations USING gist ((location::geography));");

            migrationBuilder.Sql(
                """
                ALTER TABLE healthcare_appointments
                ADD CONSTRAINT ex_healthcare_appointments_no_overlap
                EXCLUDE USING gist (
                    healthcare_provider_id WITH =,
                    tstzrange(start_at, end_at, '[)') WITH &&
                )
                WHERE (status IN ('PENDING', 'CONFIRMED'));
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE healthcare_appointments DROP CONSTRAINT IF EXISTS ex_healthcare_appointments_no_overlap;");

            migrationBuilder.Sql(
                "DROP INDEX IF EXISTS ix_provider_locations_location_geog;");

            migrationBuilder.DropTable(
                name: "appointment_status_history");

            migrationBuilder.DropTable(
                name: "customer_profiles");

            migrationBuilder.DropTable(
                name: "food_order_delivery_info");

            migrationBuilder.DropTable(
                name: "food_order_items");

            migrationBuilder.DropTable(
                name: "food_order_status_history");

            migrationBuilder.DropTable(
                name: "healthcare_location_settings");

            migrationBuilder.DropTable(
                name: "notification_preferences");

            migrationBuilder.DropTable(
                name: "notifications");

            migrationBuilder.DropTable(
                name: "provider_schedules");

            migrationBuilder.DropTable(
                name: "refresh_tokens");

            migrationBuilder.DropTable(
                name: "restaurant_location_settings");

            migrationBuilder.DropTable(
                name: "restaurant_operating_hours");

            migrationBuilder.DropTable(
                name: "reviews");

            migrationBuilder.DropTable(
                name: "schedule_exceptions");

            migrationBuilder.DropTable(
                name: "service_request_status_history");

            migrationBuilder.DropTable(
                name: "user_roles");

            migrationBuilder.DropTable(
                name: "menu_items");

            migrationBuilder.DropTable(
                name: "food_orders");

            migrationBuilder.DropTable(
                name: "healthcare_appointments");

            migrationBuilder.DropTable(
                name: "service_requests");

            migrationBuilder.DropTable(
                name: "roles");

            migrationBuilder.DropTable(
                name: "menu_categories");

            migrationBuilder.DropTable(
                name: "healthcare_providers");

            migrationBuilder.DropTable(
                name: "general_providers");

            migrationBuilder.DropTable(
                name: "provider_locations");

            migrationBuilder.DropTable(
                name: "restaurants");

            migrationBuilder.DropTable(
                name: "medical_specialties");

            migrationBuilder.DropTable(
                name: "services");

            migrationBuilder.DropTable(
                name: "zones");

            migrationBuilder.DropTable(
                name: "providers");

            migrationBuilder.DropTable(
                name: "service_categories");

            migrationBuilder.DropTable(
                name: "users");
        }
    }
}
