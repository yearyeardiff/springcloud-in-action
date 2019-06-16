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
    private HelloServiceClient helloServiceClient;


    @GetMapping("/test")
    public String test(String name) {
        return helloServiceClient.hello(name);
    }
}
