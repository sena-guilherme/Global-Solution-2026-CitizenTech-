package br.com.fiap.agrosync.dto;

import java.time.LocalDateTime;
import java.util.List;

public record ErroResposta(LocalDateTime timestamp, int status, String error, String message, String path,
                           List<CampoErro> fieldErrors) {

    public record CampoErro(String campo, String mensagem) {
    }
}
