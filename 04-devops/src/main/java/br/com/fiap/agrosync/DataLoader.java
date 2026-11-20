package br.com.fiap.agrosync;

import br.com.fiap.agrosync.domain.*;
import br.com.fiap.agrosync.repository.*;
import br.com.fiap.agrosync.service.AlertaService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Carga de exemplo para o ambiente Docker/nuvem (perfil "prod"), onde o banco sobe vazio.
 * No Oracle (perfil padrão) os dados vêm do script do banco, então este carregador NÃO roda.
 * Só insere dados se a tabela PRODUTOR estiver vazia. Desligue com SEED_ENABLED=false.
 */
@Component
@Profile("prod")
@ConditionalOnProperty(name = "app.seed.enabled", havingValue = "true", matchIfMissing = true)
@RequiredArgsConstructor
public class DataLoader implements CommandLineRunner {

    private final ProdutorRepository produtores;
    private final AreaRepository areas;
    private final CulturaRepository culturas;
    private final LeituraSoloRepository leituras;
    private final PublicacaoRepository publicacoes;
    private final AlertaService alertaService;
    private final PasswordEncoder encoder;

    @Override
    @Transactional
    public void run(String... args) {
        if (produtores.count() > 0) {
            return;
        }

        // admin@agrosync.com é ADMIN (app.security.admin-emails); os demais são PRODUTOR
        produtor("Administrador", "admin@agrosync.com", "Admin@123", "Sao Paulo", "Capital");
        Produtor jose = produtor("Jose Silva", "produtor@agrosync.com", "Produtor@123", "Piedade", "Sorocaba");
        Produtor maria = produtor("Dona Maria", "maria@agrosync.com", "Produtor@123", "Piedade", "Sorocaba");
        Produtor carlos = produtor("Carlos H.", "carlos@agrosync.com", "Produtor@123", "Ibiuna", "Sorocaba");

        Area horta = area(jose, "Horta Principal", 1.5, -23.7119, -47.4278);
        Cultura alface = cultura(horta, TipoCultura.HORTALICA, "Alface Crespa", 21, Estagio.CRESCIMENTO);
        leitura(horta, 22.0, OrigemLeitura.SENSOR, "ARD-001", 70);   // moderado
        leitura(horta, 45.0, OrigemLeitura.SENSOR, "ARD-001", 30);   // normal
        leitura(horta, 68.0, OrigemLeitura.SENSOR, "ARD-001", 2);    // normal

        Area pomar = area(jose, "Pomar de Morango", 3.2, -23.6564, -47.2225);
        Cultura morango = cultura(pomar, TipoCultura.FRUTA, "Morango", 35, Estagio.FLORACAO);
        leitura(pomar, 55.0, OrigemLeitura.MANUAL, null, 20);
        leitura(pomar, 18.5, OrigemLeitura.SENSOR, "ARD-002", 3);    // critico

        Area canteiro = area(maria, "Canteiro da Maria", 0.8, -23.7110, -47.4270);
        Cultura couve = cultura(canteiro, TipoCultura.HORTALICA, "Couve Manteiga", 5, Estagio.GERMINACAO);
        leitura(canteiro, 75.0, OrigemLeitura.MANUAL, null, 4);      // excesso

        // alertas de umidade gerados pela mesma regra usada na API (última leitura de cada área)
        alerta(alface, 68.0);
        alerta(morango, 18.5);
        alerta(couve, 75.0);

        publicacao(maria, "Piedade", "Alface",
                "Cobrir as mudas com sombrite de 50% salvou minha producao na onda de calor dessa semana.", 24, 14);
        publicacao(carlos, "Ibiuna", "Morango",
                "Cuidado com excesso de irrigacao noturna apos chuvas rapidas. Evitou fungo por aqui.", 48, 22);
    }

    private Produtor produtor(String nome, String email, String senha, String municipio, String regiao) {
        Produtor p = new Produtor();
        p.setNome(nome);
        p.setEmail(email);
        p.setSenha(encoder.encode(senha));
        p.setMunicipio(municipio);
        p.setRegiao(regiao);
        return produtores.save(p);
    }

    private Area area(Produtor dono, String nome, double ha, double lat, double lon) {
        Area a = new Area();
        a.setProdutor(dono);
        a.setNome(nome);
        a.setTamanhoHa(ha);
        a.setLatitude(lat);
        a.setLongitude(lon);
        return areas.save(a);
    }

    private Cultura cultura(Area area, TipoCultura tipo, String nome, int diasDesdePlantio, Estagio estagio) {
        Cultura c = new Cultura();
        c.setArea(area);
        c.setTipo(tipo);
        c.setNome(nome);
        c.setDataPlantio(LocalDate.now().minusDays(diasDesdePlantio));
        c.setEstagio(estagio);
        return culturas.save(c);
    }

    private void leitura(Area area, double umidade, OrigemLeitura origem, String dispositivo, int horasAtras) {
        LeituraSolo l = new LeituraSolo();
        l.setArea(area);
        l.setValorUmidade(umidade);
        l.setOrigem(origem);
        l.setIdDispositivo(dispositivo);
        l.setDataHora(LocalDateTime.now().minusHours(horasAtras));
        leituras.save(l);
    }

    private void alerta(Cultura cultura, double umidade) {
        alertaService.gerarPorUmidade(cultura, umidade, ClassificacaoUmidade.de(umidade));
    }

    private void publicacao(Produtor autor, String regiao, String cultura, String texto, int horasAtras, int confirmacoes) {
        Publicacao p = new Publicacao();
        p.setProdutor(autor);
        p.setRegiao(regiao);
        p.setCultura(cultura);
        p.setTexto(texto);
        p.setConfirmacoes(confirmacoes);
        p.setDataPublicacao(LocalDateTime.now().minusHours(horasAtras));
        publicacoes.save(p);
    }
}
