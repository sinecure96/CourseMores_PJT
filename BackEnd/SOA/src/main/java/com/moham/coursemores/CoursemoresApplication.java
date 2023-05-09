package com.moham.coursemores;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
public class CoursemoresApplication {

	public static void main(String[] args) {
		SpringApplication.run(CoursemoresApplication.class, args);
	}

}
