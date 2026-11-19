using System.ComponentModel.DataAnnotations;

namespace AgroSync.Api.Dtos;

public class LeituraSoloRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "Informe o id de uma área válida.")]
    public int AreaId { get; set; }

    [Range(0.0, 100.0, ErrorMessage = "A umidade deve estar entre 0 e 100%.")]
    public decimal UmidadePercentual { get; set; }

    public DateTime? DataHora { get; set; }

    [Required(ErrorMessage = "A origem é obrigatória.")]
    [RegularExpression("^(SENSOR|MANUAL)$", ErrorMessage = "A origem deve ser SENSOR ou MANUAL.")]
    public string Origem { get; set; } = string.Empty;

    [StringLength(50, ErrorMessage = "O id do dispositivo deve ter no máximo 50 caracteres.")]
    public string? DispositivoId { get; set; }
}