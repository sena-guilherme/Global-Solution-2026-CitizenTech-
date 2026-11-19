using AgroSync.Api.Data;
using AgroSync.Api.Dtos;
using AgroSync.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AgroSync.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LeiturasController : ControllerBase
{
    private readonly AppDbContext _context;

    public LeiturasController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<LeituraSoloResponse>>> GetAll([FromQuery] int? areaId)
    {
        var query = _context.Leituras.AsNoTracking();

        if (areaId.HasValue)
            query = query.Where(l => l.AreaId == areaId.Value);

        var leituras = await query.OrderBy(l => l.Id).ToListAsync();

        return Ok(leituras.Select(ToResponse));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<LeituraSoloResponse>> GetById(int id)
    {
        var leitura = await _context.Leituras
            .AsNoTracking()
            .FirstOrDefaultAsync(l => l.Id == id);

        if (leitura is null)
            return NotFound(new { mensagem = $"Leitura {id} não encontrada." });

        return Ok(ToResponse(leitura));
    }

    [HttpPost]
    public async Task<ActionResult<LeituraSoloResponse>> Create(LeituraSoloRequest request)
    {
        var area = await _context.Areas.FindAsync(request.AreaId);
        if (area is null)
            return AreaNaoEncontrada(request.AreaId);

        var leitura = new LeituraSolo
        {
            AreaId = request.AreaId,
            UmidadePercentual = request.UmidadePercentual,
            DataHora = request.DataHora ?? DateTime.UtcNow,
            Origem = request.Origem,
            DispositivoId = request.DispositivoId
        };

        _context.Leituras.Add(leitura);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = leitura.Id }, ToResponse(leitura));
    }

    private ActionResult AreaNaoEncontrada(int areaId)
    {
        ModelState.AddModelError(nameof(LeituraSoloRequest.AreaId), $"A área {areaId} não existe.");
        return ValidationProblem(ModelState);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, LeituraSoloRequest request)
    {
        var leitura = await _context.Leituras.FindAsync(id);

        if (leitura is null)
            return NotFound(new { mensagem = $"Leitura {id} não encontrada." });

        var area = await _context.Areas.FindAsync(request.AreaId);
        if (area is null)
            return AreaNaoEncontrada(request.AreaId);

        leitura.AreaId = request.AreaId;
        leitura.UmidadePercentual = request.UmidadePercentual;
        leitura.DataHora = request.DataHora ?? leitura.DataHora;
        leitura.Origem = request.Origem;
        leitura.DispositivoId = request.DispositivoId;

        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var leitura = await _context.Leituras.FindAsync(id);

        if (leitura is null)
            return NotFound(new { mensagem = $"Leitura {id} não encontrada." });

        _context.Leituras.Remove(leitura);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private static LeituraSoloResponse ToResponse(LeituraSolo l) =>
        new(l.Id, l.AreaId, l.UmidadePercentual, l.DataHora, l.Origem, l.DispositivoId);
}