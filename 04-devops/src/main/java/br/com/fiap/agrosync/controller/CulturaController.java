package br.com.fiap.agrosync.controller;

import br.com.fiap.agrosync.dto.AreaDtos.CulturaRequest;
import br.com.fiap.agrosync.dto.AreaDtos.CulturaResponse;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.service.CulturaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/culturas")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Culturas", description = "Edição e exclusão de culturas (o cadastro é feito em /api/areas)")
public class CulturaController {

    private final CulturaService service;

    @Operation(summary = "Atualiza tipo, nome, data de plantio ou estágio da cultura")
    @PutMapping("/{id}")
    public CulturaResponse atualizar(@PathVariable Long id, @Valid @RequestBody CulturaRequest req,
                                     @AuthenticationPrincipal UsuarioLogado usuario) {
        return service.atualizar(id, req, usuario);
    }

    @Operation(summary = "Exclui a cultura e os alertas ligados a ela")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario) {
        service.excluir(id, usuario);
    }
}
