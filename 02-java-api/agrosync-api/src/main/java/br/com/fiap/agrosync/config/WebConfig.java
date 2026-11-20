package br.com.fiap.agrosync.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

/** Serve as fotos enviadas em /uploads/** (leitura pública, como em uma rede social). */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final String pasta;

    public WebConfig(@Value("${app.upload-dir:uploads}") String pasta) {
        this.pasta = pasta;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String local = Paths.get(pasta).toAbsolutePath().normalize().toUri().toString();
        if (!local.endsWith("/")) {
            local += "/";
        }
        registry.addResourceHandler("/uploads/**").addResourceLocations(local);
    }
}
