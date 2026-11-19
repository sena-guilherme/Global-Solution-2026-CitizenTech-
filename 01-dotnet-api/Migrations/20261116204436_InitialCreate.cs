using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AgroSync.Api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AREA",
                columns: table => new
                {
                    ID_AREA = table.Column<int>(type: "NUMBER(10)", nullable: false)
                        .Annotation("Oracle:Identity", "START WITH 1 INCREMENT BY 1"),
                    NOME = table.Column<string>(type: "NVARCHAR2(100)", maxLength: 100, nullable: false),
                    TAMANHO_HA = table.Column<decimal>(type: "DECIMAL(10,2)", precision: 10, scale: 2, nullable: false),
                    LATITUDE = table.Column<decimal>(type: "DECIMAL(9,6)", precision: 9, scale: 6, nullable: false),
                    LONGITUDE = table.Column<decimal>(type: "DECIMAL(9,6)", precision: 9, scale: 6, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AREA", x => x.ID_AREA);
                });

            migrationBuilder.CreateTable(
                name: "LEITURA_SOLO",
                columns: table => new
                {
                    ID_LEITURA = table.Column<int>(type: "NUMBER(10)", nullable: false)
                        .Annotation("Oracle:Identity", "START WITH 1 INCREMENT BY 1"),
                    ID_AREA = table.Column<int>(type: "NUMBER(10)", nullable: false),
                    UMIDADE_PCT = table.Column<decimal>(type: "DECIMAL(5,2)", precision: 5, scale: 2, nullable: false),
                    DATA_HORA = table.Column<DateTime>(type: "TIMESTAMP(7)", nullable: false),
                    ORIGEM = table.Column<string>(type: "NVARCHAR2(10)", maxLength: 10, nullable: false),
                    DISPOSITIVO_ID = table.Column<string>(type: "NVARCHAR2(50)", maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LEITURA_SOLO", x => x.ID_LEITURA);
                    table.ForeignKey(
                        name: "FK_LEITURA_SOLO_AREA_ID_AREA",
                        column: x => x.ID_AREA,
                        principalTable: "AREA",
                        principalColumn: "ID_AREA",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_LEITURA_SOLO_ID_AREA",
                table: "LEITURA_SOLO",
                column: "ID_AREA");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "LEITURA_SOLO");

            migrationBuilder.DropTable(
                name: "AREA");
        }
    }
}
