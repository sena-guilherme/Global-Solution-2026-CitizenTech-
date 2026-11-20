package br.com.fiap.agrosync.controller;

import br.com.fiap.agrosync.dto.RelatorioDtos.RelatorioResponse;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.service.RelatorioService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/relatorio")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Relatório", description = "Relatório consolidado do produtor (equivale à procedure sp_relatorio_produtor)")
public class RelatorioController {

    private final RelatorioService service;

    @Operation(summary = "Relatório do produtor logado: áreas, alertas, críticos e a última umidade de cada área")
    @GetMapping
    public RelatorioResponse meu(@AuthenticationPrincipal UsuarioLogado usuario) {
        return service.gerar(usuario.getId(), usuario);
    }

    @Operation(summary = "Relatório de um produtor (somente ele mesmo ou um administrador)")
    @GetMapping("/{produtorId}")
    public RelatorioResponse deProdutor(@PathVariable Long produtorId, @AuthenticationPrincipal UsuarioLogado usuario) {
        return service.gerar(produtorId, usuario);
    }
}
