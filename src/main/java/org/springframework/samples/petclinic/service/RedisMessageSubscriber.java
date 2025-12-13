/*
 * Copyright 2012-2025 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.stereotype.Service;

/**
 * Service for subscribing to Redis messages.
 *
 * @author PetClinic Team
 */
@Service
public class RedisMessageSubscriber implements MessageListener {

	private static final Logger logger = LoggerFactory.getLogger(RedisMessageSubscriber.class);

	@Override
	public void onMessage(Message message, byte[] pattern) {
		logger.info("Received message: {} from channel: {}", new String(message.getBody()),
				new String(message.getChannel()));
	}

}