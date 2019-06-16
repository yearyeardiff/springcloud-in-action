/**
 * $Id: HystrixappApplication.java,v 1.0 2019/6/5 15:27 ZCH Exp $
 * <p>
 * Copyright 2016 Asiainfo Technologies(China),Inc. All rights reserved.
 */

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;
import org.springframework.context.annotation.ComponentScan;

/**
 * $Id: HystrixappApplication.java,v 1.0 2019/6/5 15:27 ZCH Exp $
 * 参考：https://www.yiibai.com/spring-boot/spring_boot_hystrix.html#article-start
 * @author zch
 */
@SpringBootApplication
@EnableHystrix
@ComponentScan({"controller"})
public class HystrixappApplication {
    public static void main(String[] args) {
        SpringApplication.run(HystrixappApplication.class, args);
    }
}

