namespace AgroSync.Api.Models;

public class Area
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public decimal TamanhoHectares { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }

    public List<LeituraSolo> Leituras { get; set; } = new();
}