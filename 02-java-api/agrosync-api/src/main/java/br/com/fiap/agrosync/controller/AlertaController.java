package br.com.fiap.agrosync.controller;

import br.com.fiap.agrosync.domain.Severidade;
import br.com.fiap.agrosync.domain.TipoAlerta;
import br.com.fiap.agrosync.dto.AlertaDtos.AlertaRequest;
import br.com.fiap.agrosync.dto.AlertaDtos.AlertaResponse;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.service.AlertaService;
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
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/alertas")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Alertas", description = "Alertas de umidade, clima e irrigação das culturas do produtor")
public class AlertaController {

    private final AlertaService service;

    @Operation(summary = "Lista os alertas do produtor, com filtros de tipo, severidade e lido")
    @GetMapping
    public Page<AlertaResponse> listar(@AuthenticationPrincipal UsuarioLogado usuario,
                                       @RequestParam(required = false) TipoAlerta tipo,
                                       @RequestParam(required = false) Severidade severidade,
                                       @RequestParam(required = false) Boolean lido,
                                       @PageableDefault(size = 20, sort = "dataGeracao", direction = Sort.Direction.DESC) Pageable pageable) {
        return service.listar(usuario, tipo, severidade, lido, pageable);
    }

    @Operation(summary = "Quantidade de alertas ainda não lidos")
    @GetMapping("/nao-lidos")
    public Map<String, Long> naoLidos(@AuthenticationPrincipal UsuarioLogado usuario) {
        return Map.of("quantidade", service.contarNaoLidos(usuario));
    }

    @Operation(summary = "Marca um alerta como lido")
    @PatchMapping("/{id}/lido")
    public AlertaResponse marcarLido(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario) {
        return service.marcarLido(id, usuario);
    }

    @Operation(summary = "[ADMIN] Cria um alerta para uma cultura, uma região ou todas as culturas")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public List<AlertaResponse> criar(@Valid @RequestBody AlertaRequest req) {
        return service.criar(req);
    }

    @Operation(summary = "[ADMIN] Exclui um alerta")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@PathVariable Long id) {
        service.excluir(id);
    }
}
