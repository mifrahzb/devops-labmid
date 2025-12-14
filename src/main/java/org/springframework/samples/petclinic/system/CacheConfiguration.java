package org.springframework.samples.petclinic.system;

import java.time.Duration;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.jsontype.BasicPolymorphicTypeValidator;
import com.fasterxml.jackson.datatype.hibernate5.jakarta.Hibernate5JakartaModule;

/**
 * Cache configuration using Redis with proper Hibernate entity serialization support.
 */
@Configuration(proxyBeanMethods = false)
@EnableCaching
class CacheConfiguration {

	@Bean
	public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {
		// Create ObjectMapper with Hibernate support
		ObjectMapper mapper = new ObjectMapper();
		
		// Register Hibernate5 module to handle JPA entities and proxies
		Hibernate5JakartaModule hibernateModule = new Hibernate5JakartaModule();
		hibernateModule.enable(Hibernate5JakartaModule.Feature.FORCE_LAZY_LOADING);
		mapper.registerModule(hibernateModule);
		
		// Disable failing on empty beans
		mapper.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
		
		// Enable default typing for proper deserialization
		mapper.activateDefaultTyping(
			BasicPolymorphicTypeValidator.builder()
				.allowIfBaseType(Object.class)
				.build(),
			ObjectMapper.DefaultTyping.NON_FINAL,
			JsonTypeInfo.As.PROPERTY
		);

		GenericJackson2JsonRedisSerializer serializer = new GenericJackson2JsonRedisSerializer(mapper);

		RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
			.entryTtl(Duration.ofMinutes(10))
			.disableCachingNullValues()
			.serializeKeysWith(
				RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
			.serializeValuesWith(
				RedisSerializationContext.SerializationPair.fromSerializer(serializer));

		return RedisCacheManager.builder(connectionFactory)
			.cacheDefaults(config)
			.build();
	}

}