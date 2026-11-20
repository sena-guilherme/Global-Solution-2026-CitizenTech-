package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.domain.Area;
import br.com.fiap.agrosync.domain.Cultura;
import br.com.fiap.agrosync.domain.LeituraSolo;
import br.com.fiap.agrosync.dto.AreaDtos.AreaRequest;
import br.com.fiap.agrosync.dto.AreaDtos.AreaResponse;
import br.com.fiap.agrosync.dto.AreaDtos.CulturaRequest;
import br.com.fiap.agrosync.exception.RecursoNaoEncontradoException;
import br.com.fiap.agrosync.repository.AreaRepository;
import br.com.fiap.agrosync.repository.CulturaRepository;
import br.com.fiap.agrosync.repository.LeituraSoloRepository;
import br.com.fiap.agrosync.repository.ProdutorRepository;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.spec.AreaSpecs;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AreaService {

    private final AreaRepository areas;
    private final ProdutorRepository produtores;
    private final CulturaRepository culturas;
    private final LeituraSoloRepository leituras;

    @Transactional(readOnly = true)
    public Page<AreaResponse> listar(UsuarioLogado usuario, String nome, Pageable pageable) {
        Specification<Area> spec = AreaSpecs.visivelPara(usuario).and(AreaSpecs.nome(nome));
        return areas.findAll(spec, pageable).map(this::resposta);
    }

    @Transactional(readOnly = true)
    public AreaResponse buscar(Long id, UsuarioLogado usuario) {
        return resposta(carregar(id, usuario));
    }

    @Transactional
    public AreaResponse criar(AreaRequest req, UsuarioLogado usuario) {
        Area a = new Area();
        a.setProdutor(produtores.getReferenceById(usuario.getId()));
        aplicar(a, req);
        Area salva = areas.save(a);
        if (req.cultura() != null) {
            Cultura c = new Cultura();
            c.setArea(salva);
            aplicarCultura(c, req.cultura());
            culturas.save(c);
        }
        return resposta(salva);
    }

    @Transactional
    public AreaResponse atualizar(Long id, AreaRequest req, UsuarioLogado usuario) {
        Area a = carregar(id, usuario);
        aplicar(a, req);
        if (req.cultura() != null) {
            Optional<Cultura> atual = culturas.findFirstByAreaIdOrderByDataPlantioDescIdDesc(a.getId());
            Cultura c = atual.orElseGet(() -> {
                Cultura nova = new Cultura();
                nova.setArea(a);
                return nova;
            });
            aplicarCultura(c, req.cultura());
            culturas.save(c);
        }
        return resposta(a);
    }

    @Transactional
    public void excluir(Long id, UsuarioLogado usuario) {
        areas.delete(carregar(id, usuario));
    }

    public Area carregar(Long id, UsuarioLogado usuario) {
        Area a = areas.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Área não encontrada."));
        if (!usuario.isAdmin() && !a.getProdutor().getId().equals(usuario.getId())) {
            throw new AccessDeniedException("Área de outro produtor");
        }
        return a;
    }

    private AreaResponse resposta(Area a) {
        Cultura cultura = culturas.findFirstByAreaIdOrderByDataPlantioDescIdDesc(a.getId()).orElse(null);
        LeituraSolo ultima = leituras.findFirstByAreaIdOrderByDataHoraDescIdDesc(a.getId()).orElse(null);
        return AreaResponse.de(a, cultura, ultima);
    }

    private void aplicar(Area a, AreaRequest req) {
        a.setNome(req.nome().trim());
        a.setTamanhoHa(req.tamanhoHa());
        a.setLatitude(req.latitude());
        a.setLongitude(req.longitude());
    }

    static void aplicarCultura(Cultura c, CulturaRequest req) {
        c.setTipo(req.tipo());
        c.setNome(req.nome().trim());
        c.setDataPlantio(req.dataPlantio());
        c.setEstagio(req.estagio());
    }
}
