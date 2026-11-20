package br.com.fiap.agrosync;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.web.config.EnableSpringDataWebSupport;

import static org.springframework.data.web.config.EnableSpringDataWebSupport.PageSerializationMode.VIA_DTO;

@SpringBootApplication
// Garante um JSON de paginação estável: { "content": [...], "page": { size, number, totalElements, totalPages } }
@EnableSpringDataWebSupport(pageSerializationMode = VIA_DTO)
public class AgroSyncApplication {

    public static void main(String[] args) {
        SpringApplication.run(AgroSyncApplication.class, args);
    }
}
