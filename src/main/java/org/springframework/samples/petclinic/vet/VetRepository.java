package org.springframework.samples.petclinic.vet;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;

/**
 * Repository class for <code>Vet</code> domain objects.
 */
public interface VetRepository extends Repository<Vet, Integer> {

	/**
	 * Retrieve all <code>Vet</code>s from the data store.
	 * @return a <code>Collection</code> of <code>Vet</code>s
	 */
	@Transactional(readOnly = true)
	@Cacheable("vets")
	Collection<Vet> findAll() throws DataAccessException;

	/**
	 * Retrieve all <code>Vet</code>s from data store in Pages
	 * NOTE: We don't cache this because Page objects can't be serialized to Redis
	 */
	@Transactional(readOnly = true)
	// REMOVED @Cacheable("vets") from here!
	Page<Vet> findAll(Pageable pageable) throws DataAccessException;

}