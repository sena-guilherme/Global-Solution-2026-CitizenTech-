using AgroSync.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AgroSync.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Area> Areas => Set<Area>();
    public DbSet<LeituraSolo> Leituras => Set<LeituraSolo>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Area>(e =>
        {
            e.ToTable("AREA");
            e.HasKey(a => a.Id);
            e.Property(a => a.Id).HasColumnName("ID_AREA");
            e.Property(a => a.Nome).HasColumnName("NOME").HasMaxLength(100).IsRequired();
            e.Property(a => a.TamanhoHectares).HasColumnName("TAMANHO_HA").HasPrecision(10, 2);
            e.Property(a => a.Latitude).HasColumnName("LATITUDE").HasPrecision(9, 6);
            e.Property(a => a.Longitude).HasColumnName("LONGITUDE").HasPrecision(9, 6);
        });

        modelBuilder.Entity<LeituraSolo>(e =>
        {
            e.ToTable("LEITURA_SOLO");
            e.HasKey(l => l.Id);
            e.Property(l => l.Id).HasColumnName("ID_LEITURA");
            e.Property(l => l.AreaId).HasColumnName("ID_AREA");
            e.Property(l => l.UmidadePercentual).HasColumnName("UMIDADE_PCT").HasPrecision(5, 2);
            e.Property(l => l.DataHora).HasColumnName("DATA_HORA");
            e.Property(l => l.Origem).HasColumnName("ORIGEM").HasMaxLength(10).IsRequired();
            e.Property(l => l.DispositivoId).HasColumnName("DISPOSITIVO_ID").HasMaxLength(50);

            e.HasOne(l => l.Area)
             .WithMany(a => a.Leituras)
             .HasForeignKey(l => l.AreaId)
             .OnDelete(DeleteBehavior.Cascade);
        });
    }
}