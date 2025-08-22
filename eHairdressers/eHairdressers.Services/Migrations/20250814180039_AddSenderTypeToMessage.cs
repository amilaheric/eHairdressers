using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eHairdressers.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddSenderTypeToMessage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SenderType",
                table: "Messages",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SenderType",
                table: "Messages");
        }
    }
}
