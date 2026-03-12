# Network Scanner Skill

网络扫描和诊断工具。

## 功能

- **port-scan**: 扫描指定主机的端口
- **host-discover**: 发现局域网内的活跃主机
- **service-detect**: 检测服务版本信息
- **ping**: Ping 测试
- **dns-lookup**: DNS 查询
- **traceroute**: 路由追踪

## 使用方法

```bash
network-scanner <command> [options]
```

## 命令

### port-scan
扫描目标主机的端口。

```bash
network-scanner port-scan <host> [ports]
# 示例
network-scanner port-scan 192.168.1.1 80,443,8080
network-scanner port-scan example.com 1-1000
```

### host-discover
发现局域网内的活跃主机。

```bash
network-scanner host-discover [range]
# 示例
network-scanner host-discover 192.168.1.1/24
network-scanner host-discover 10.0.0.1-254
```

### service-detect
检测服务版本信息。

```bash
network-scanner service-detect <host> <port>
# 示例
network-scanner service-detect example.com 443
```

### ping
Ping 测试。

```bash
network-scanner ping <host> [count]
# 示例
network-scanner ping example.com 5
```

### dns-lookup
DNS 查询。

```bash
network-scanner dns-lookup <domain>
# 示例
network-scanner dns-lookup example.com
```

### traceroute
路由追踪。

```bash
network-scanner traceroute <host>
# 示例
network-scanner traceroute example.com
```

## 示例输出

```
$ network-scanner port-scan localhost 80,443,8080
Scanning localhost...
Port 80:   OPEN   (HTTP)
Port 443:  OPEN   (HTTPS)
Port 8080: OPEN   (HTTP Proxy)

$ network-scanner host-discover 192.168.1.1/24
Discovering hosts in 192.168.1.1/24...
192.168.1.1   ACTIVE  (Gateway)
192.168.1.5   ACTIVE
192.168.1.10  ACTIVE
Found 3 active hosts.
```

## 简历亮点

- 网络编程能力
- 系统管理能力
- 安全意识
- CLI 工具开发
