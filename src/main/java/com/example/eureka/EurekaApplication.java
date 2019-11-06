package com.example.eureka;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * EurekaApplication start
 *
 * @author liyongjian5179
 */

@EnableEurekaServer
@SpringBootApplication


public class EurekaApplication {

	public static void main(String[] args) {
		Logger logger = LogManager.getLogger(EurekaApplication.class);
		logger.info("EurekaApplication start");
		SpringApplication.run(EurekaApplication.class, args);
	}

}


