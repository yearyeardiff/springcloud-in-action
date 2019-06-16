package consumer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

/**
 * @author zhangchenghao
 */
@RestController
public class TestController {

    @Autowired
    private RestTemplate restTemplate;


    @GetMapping("/test")
    public String test(String name) {
        return restTemplate.getForObject("http://eureka-feign-client/hello?name={1}", String.class, name);
    }
}
