package br.com.fiap.agrosync.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "LEITURA_SOLO")
@Getter
@Setter
@NoArgsConstructor
public class LeituraSolo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_leitura")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_area", nullable = false)
    private Area area;

    @Column(name = "valor_umidade", nullable = false)
    private Double valorUmidade;

    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(name = "origem", nullable = false, length = 10)
    private OrigemLeitura origem;

    @Column(name = "id_dispositivo", length = 50)
    private String idDispositivo;
}
