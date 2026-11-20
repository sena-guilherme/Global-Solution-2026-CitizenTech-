package br.com.fiap.agrosync.repository;

import br.com.fiap.agrosync.domain.Alerta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AlertaRepository extends JpaRepository<Alerta, Long>, JpaSpecificationExecutor<Alerta> {

    long countByCulturaAreaProdutorIdAndLidoFalse(Long produtorId);

    // JPQL: totais do relatório do produtor (equivalente a sp_relatorio_produtor)
    @Query("select count(a) from Alerta a where a.cultura.area.produtor.id = :produtorId")
    long contarPorProdutor(@Param("produtorId") Long produtorId);

    @Query("select count(a) from Alerta a where a.cultura.area.produtor.id = :produtorId and a.severidade = br.com.fiap.agrosync.domain.Severidade.CRITICO")
    long contarCriticosPorProdutor(@Param("produtorId") Long produtorId);
}
