package br.com.fiap.agrosync.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/** Tabela ALERTA: a interpretação da leitura (ou aviso de clima/irrigação) de uma cultura. */
@Entity
@Table(name = "ALERTA")
@Getter
@Setter
@NoArgsConstructor
public class Alerta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_alerta")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_cultura", nullable = false)
    private Cultura cultura;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false, length = 20)
    private TipoAlerta tipo;

    @Enumerated(EnumType.STRING)
    @Column(name = "severidade", nullable = false, length = 15)
    private Severidade severidade;

    @Column(name = "mensagem", nullable = false)
    private String mensagem;

    @Convert(converter = SimNaoConverter.class)
    @Column(name = "lido", nullable = false, length = 1)
    private boolean lido;

    @Column(name = "data_geracao", nullable = false)
    private LocalDateTime dataGeracao = LocalDateTime.now();
}
