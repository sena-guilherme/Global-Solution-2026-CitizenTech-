package br.com.fiap.agrosync.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/status")
@Tag(name = "Status", description = "Verificação simples de que a API está no ar (usada pelo app)")
public class StatusController {

    @Operation(summary = "Informa se a API está no ar (público, sem autenticação)")
    @GetMapping
    public Map<String, Object> status() {
        return Map.of("status", "UP", "servico", "AgroSync API", "horario", LocalDateTime.now().toString());
    }
}
