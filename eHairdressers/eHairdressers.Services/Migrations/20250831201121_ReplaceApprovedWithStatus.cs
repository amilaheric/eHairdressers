using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eHairdressers.Services.Migrations
{
    /// <inheritdoc />
    public partial class ReplaceApprovedWithStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Approved",
                table: "Appointments");

            migrationBuilder.AddColumn<string>(
                name: "Status",
                table: "Appointments",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Status",
                table: "Appointments");

            migrationBuilder.AddColumn<bool>(
                name: "Approved",
                table: "Appointments",
                type: "bit",
                nullable: true);
        }
    }
}
