package com.zhang.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * @author zhangchenghao
 */
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerHaApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurekaServerHaApplication.class, args);
    }

    //java -jar xxxx.jar --spring.profiles.active=yyy
}
