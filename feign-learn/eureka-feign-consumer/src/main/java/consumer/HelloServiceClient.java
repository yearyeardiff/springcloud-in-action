package consumer;

import api.HelloService;
import org.springframework.cloud.netflix.feign.FeignClient;

/**
 *  1. fallback
 */
/*@FeignClient(value = "eureka-feign-client", fallback = HelloServiceClientHystrix.class)
interface HelloServiceClient extends HelloService {
}*/

/**
 * 2. fallbackFactory 可以打印出异常信息
 * If one needs access to the cause that made the fallback trigger,
 * one can use the fallbackFactory attribute inside @FeignClient.
 */
@FeignClient(value = "eureka-feign-client", fallbackFactory = HelloServiceClientHystrixFactory.class)
interface HelloServiceClient extends HelloService {
}
