package org.feuyeux.http.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.*;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

public class Networking {
    private static final Logger LOGGER = LoggerFactory.getLogger(Networking.class);

    static String getLocalIp() {
        try {
            InetAddress inetAddress = InetAddress.getLocalHost();
            if (!isValidAddress(inetAddress)) {
                return getLocalhostByNetworkInterface();
            } else {
                return inetAddress.getHostAddress();
            }
        } catch (UnknownHostException | SocketException e) {
            LOGGER.error("", e);
            return null;
        }
    }

    static String getLocalhostByNetworkInterface() throws SocketException {
        List<String> candidatesHost = new ArrayList<>();
        Enumeration<NetworkInterface> enumeration = NetworkInterface.getNetworkInterfaces();

        while (enumeration.hasMoreElements()) {
            NetworkInterface networkInterface = enumeration.nextElement();
            // Workaround for docker0 bridge
            if ("docker0".equals(networkInterface.getName()) || !networkInterface.isUp()) {
                continue;
            }
            Enumeration<InetAddress> addrs = networkInterface.getInetAddresses();
            while (addrs.hasMoreElements()) {
                InetAddress address = addrs.nextElement();
                if (!isValidAddress(address)) {
                    continue;
                }
                // ip4 highter priority
                if (address instanceof Inet6Address) {
                    candidatesHost.add(address.getHostAddress());
                    continue;
                }
                return address.getHostAddress();
            }
        }

        if (!candidatesHost.isEmpty()) {
            return candidatesHost.get(0);
        }
        return null;
    }

    static boolean isValidAddress(InetAddress address) {
        return address != null
                && !address.isLoopbackAddress() // filter 127.x.x.x
                && !address.isAnyLocalAddress() // filter 0.0.0.0
                && !address.isLinkLocalAddress(); // filter 169.254.0.0/16
    }
}
