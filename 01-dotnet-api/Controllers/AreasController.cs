using AgroSync.Api.Data;
using AgroSync.Api.Dtos;
using AgroSync.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AgroSync.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AreasController : ControllerBase
{
    private readonly AppDbContext _context;

    public AreasController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<AreaResponse>>> GetAll()
    {
        var areas = await _context.Areas
            .AsNoTracking()
            .OrderBy(a => a.Id)
            .ToListAsync();

        return Ok(areas.Select(ToResponse));
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AreaResponse>> GetById(int id)
    {
        var area = await _context.Areas
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == id);

        if (area is null)
            return NotFound(new { mensagem = $"Área {id} não encontrada." });

        return Ok(ToResponse(area));
    }

    [HttpPost]
    public async Task<ActionResult<AreaResponse>> Create(AreaRequest request)
    {
        var area = new Area
        {
            Nome = request.Nome,
            TamanhoHectares = request.TamanhoHectares,
            Latitude = request.Latitude,
            Longitude = request.Longitude
        };

        _context.Areas.Add(area);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = area.Id }, ToResponse(area));
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, AreaRequest request)
    {
        var area = await _context.Areas.FindAsync(id);

        if (area is null)
            return NotFound(new { mensagem = $"Área {id} não encontrada." });

        area.Nome = request.Nome;
        area.TamanhoHectares = request.TamanhoHectares;
        area.Latitude = request.Latitude;
        area.Longitude = request.Longitude;

        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var area = await _context.Areas.FindAsync(id);

        if (area is null)
            return NotFound(new { mensagem = $"Área {id} não encontrada." });

        _context.Areas.Remove(area);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private static AreaResponse ToResponse(Area area) =>
        new(area.Id, area.Nome, area.TamanhoHectares, area.Latitude, area.Longitude);
}