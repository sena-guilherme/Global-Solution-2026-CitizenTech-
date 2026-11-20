package br.com.fiap.agrosync.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Tabela AREA: o pedaço de terra do produtor. */
@Entity
@Table(name = "AREA")
@Getter
@Setter
@NoArgsConstructor
public class Area {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_area")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_produtor", nullable = false)
    private Produtor produtor;

    @Column(name = "nome", nullable = false, length = 100)
    private String nome;

    @Column(name = "tamanho_ha", nullable = false)
    private Double tamanhoHa;

    @Column(name = "latitude", nullable = false)
    private Double latitude;

    @Column(name = "longitude", nullable = false)
    private Double longitude;

    @Column(name = "data_cadastro", nullable = false)
    private LocalDateTime dataCadastro = LocalDateTime.now();

    /** Excluir a área exclui suas culturas (e alertas) e leituras: as FKs do banco não têm CASCADE. */
    @OneToMany(mappedBy = "area", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Cultura> culturas = new ArrayList<>();

    @OneToMany(mappedBy = "area", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<LeituraSolo> leituras = new ArrayList<>();
}
