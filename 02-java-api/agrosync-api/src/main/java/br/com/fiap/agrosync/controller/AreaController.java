package br.com.fiap.agrosync.controller;

import br.com.fiap.agrosync.dto.AlertaDtos.AlertaResponse;
import br.com.fiap.agrosync.dto.AreaDtos.*;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.service.AreaService;
import br.com.fiap.agrosync.service.CulturaService;
import br.com.fiap.agrosync.service.LeituraService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/areas")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Áreas", description = "Áreas de cultivo, culturas, leituras de umidade do solo e irrigação")
public class AreaController {

    private final AreaService areas;
    private final CulturaService culturas;
    private final LeituraService leituras;

    @Operation(summary = "Lista as áreas do produtor (admin vê todas) com cultura atual e última leitura; filtro por nome, paginação e ordenação")
    @GetMapping
    public Page<AreaResponse> listar(@AuthenticationPrincipal UsuarioLogado usuario,
                                     @RequestParam(required = false) String nome,
                                     @PageableDefault(size = 20, sort = "nome", direction = Sort.Direction.ASC) Pageable pageable) {
        return areas.listar(usuario, nome, pageable);
    }

    @Operation(summary = "Busca uma área pelo id")
    @GetMapping("/{id}")
    public AreaResponse buscar(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario) {
        return areas.buscar(id, usuario);
    }

    @Operation(summary = "Cadastra uma área (e, opcionalmente, a cultura plantada nela)")
    @PostMapping
    public ResponseEntity<AreaResponse> criar(@Valid @RequestBody AreaRequest req,
                                              @AuthenticationPrincipal UsuarioLogado usuario) {
        AreaResponse criada = areas.criar(req, usuario);
        var local = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}").buildAndExpand(criada.id()).toUri();
        return ResponseEntity.created(local).body(criada);
    }

    @Operation(summary = "Atualiza a área e, se informada, a cultura atual")
    @PutMapping("/{id}")
    public AreaResponse atualizar(@PathVariable Long id, @Valid @RequestBody AreaRequest req,
                                  @AuthenticationPrincipal UsuarioLogado usuario) {
        return areas.atualizar(id, req, usuario);
    }

    @Operation(summary = "Exclui a área com suas culturas, alertas e leituras")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario) {
        areas.excluir(id, usuario);
    }

    // ---------------- culturas da área ----------------
    @Operation(summary = "Lista as culturas da área (mais recente primeiro)")
    @GetMapping("/{id}/culturas")
    public List<CulturaResponse> listarCulturas(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario) {
        return culturas.listar(id, usuario);
    }

    @Operation(summary = "Planta uma nova cultura na área (o histórico de leituras da área é mantido)")
    @PostMapping("/{id}/culturas")
    @ResponseStatus(HttpStatus.CREATED)
    public CulturaResponse adicionarCultura(@PathVariable Long id, @Valid @RequestBody CulturaRequest req,
                                            @AuthenticationPrincipal UsuarioLogado usuario) {
        return culturas.adicionar(id, req, usuario);
    }

    // ---------------- leituras e irrigação ----------------
    @Operation(summary = "Registra uma leitura de umidade (sensor ou manual): grava a leitura e gera o alerta conforme a regra de severidade")
    @PostMapping("/{id}/leituras")
    public ResponseEntity<LeituraRegistradaResponse> registrarLeitura(@PathVariable Long id,
                                                                      @Valid @RequestBody LeituraRequest req,
                                                                      @AuthenticationPrincipal UsuarioLogado usuario) {
        return ResponseEntity.status(HttpStatus.CREATED).body(leituras.registrar(id, req, usuario));
    }

    @Operation(summary = "Histórico de leituras da área (mais recentes primeiro)")
    @GetMapping("/{id}/leituras")
    public Page<LeituraResponse> listarLeituras(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario,
                                                @PageableDefault(size = 20) Pageable pageable) {
        return leituras.listar(id, usuario, pageable);
    }

    @Operation(summary = "Registra uma irrigação manual da área (gera alerta do tipo IRRIGACAO)")
    @PostMapping("/{id}/irrigacoes")
    @ResponseStatus(HttpStatus.CREATED)
    public AlertaResponse irrigar(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario) {
        return leituras.registrarIrrigacao(id, usuario);
    }
}
