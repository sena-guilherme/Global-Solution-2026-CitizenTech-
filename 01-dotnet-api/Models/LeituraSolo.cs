namespace AgroSync.Api.Models;

public class LeituraSolo
{
    public int Id { get; set; }
    public int AreaId { get; set; }
    public Area? Area { get; set; }

    public decimal UmidadePercentual { get; set; }
    public DateTime DataHora { get; set; }
    public string Origem { get; set; } = string.Empty; // Manual ou Dispositivo(sensor)
    public string? DispositivoId { get; set; }
}