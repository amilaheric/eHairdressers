using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eHairdressers.Services.Migrations
{
    /// <inheritdoc />
    public partial class RemoveAmountStateMachinePaymentIdFromProducts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Amount",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "PaymentId",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "StateMachine",
                table: "Products");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

            migrationBuilder.AddColumn<int>(
                name: "Amount",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "PaymentId",
                table: "Products",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "StateMachine",
                table: "Products",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
