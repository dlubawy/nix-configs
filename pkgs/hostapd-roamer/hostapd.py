# Python class for controlling hostapd
# Copyright (c) 2013-2019, Jouni Malinen <j@w1.fi>
#
# This software may be distributed under the terms of the BSD license.
# See README for more details.

import binascii
import logging
import os
import struct
import subprocess
import time

import wpaspy

logger = logging.getLogger()
hapd_ctrl = "/var/run/hostapd"


def mac2tuple(mac):
    return struct.unpack("6B", binascii.unhexlify(mac.replace(":", "")))


class Hostapd:
    def __init__(
        self,
        ifname,
        bssidx=0,
        hostname=None,
        ctrl=hapd_ctrl,
    ):
        self.hostname = hostname
        self.ifname = ifname
        self.ctrl = wpaspy.Ctrl(os.path.join(ctrl, ifname))
        self.mon = wpaspy.Ctrl(os.path.join(ctrl, ifname))
        self.dbg = ifname
        self.mon.attach()
        self.bssid = None
        self.bssidx = bssidx
        self.mld_addr = None

    def cmd_execute(self, cmd_array, shell=False):
        if self.hostname is None:
            if shell:
                cmd = " ".join(cmd_array)
            else:
                cmd = cmd_array
            proc = subprocess.Popen(
                cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, shell=shell
            )
            out = proc.communicate()[0]
            ret = proc.returncode
            return ret, out.decode()
        else:
            return self.host.execute(cmd_array)

    def close_ctrl(self):
        if self.mon is not None:
            self.mon.detach()
            self.mon.close()
            self.mon = None
            self.ctrl.close()
            self.ctrl = None

    def own_addr(self):
        if self.bssid is None:
            self.bssid = self.get_status_field("bssid[%d]" % self.bssidx)
        return self.bssid

    def own_mld_addr(self):
        if self.mld_addr is None:
            self.mld_addr = self.get_status_field("mld_addr[%d]" % self.bssidx)
        return self.mld_addr

    def get_addr(self, group=False):
        if self.own_mld_addr() is None:
            return self.own_addr()
        return self.own_mld_addr()

    def request(self, cmd):
        logger.debug(self.dbg + ": CTRL: " + cmd)
        return self.ctrl.request(cmd)

    def ping(self):
        return "PONG" in self.request("PING")

    def set(self, field, value):
        if "OK" not in self.request("SET " + field + " " + value):
            if "TKIP" in value and (field == "wpa_pairwise" or field == "rsn_pairwise"):
                raise OSError("Cipher TKIP not supported")
            raise Exception("Failed to set hostapd parameter " + field)

    def set_defaults(self, set_channel=True):
        self.set("driver", "nl80211")
        if set_channel:
            self.set("hw_mode", "g")
            self.set("channel", "1")
            self.set("ieee80211n", "1")
        self.set("logger_stdout", "-1")
        self.set("logger_stdout_level", "0")

    def set_open(self, ssid):
        self.set_defaults()
        self.set("ssid", ssid)

    def set_wpa2_psk(self, ssid, passphrase):
        self.set_defaults()
        self.set("ssid", ssid)
        self.set("wpa_passphrase", passphrase)
        self.set("wpa", "2")
        self.set("wpa_key_mgmt", "WPA-PSK")
        self.set("rsn_pairwise", "CCMP")

    def set_wpa_psk(self, ssid, passphrase):
        self.set_defaults()
        self.set("ssid", ssid)
        self.set("wpa_passphrase", passphrase)
        self.set("wpa", "1")
        self.set("wpa_key_mgmt", "WPA-PSK")
        self.set("wpa_pairwise", "TKIP")

    def set_wpa_psk_mixed(self, ssid, passphrase):
        self.set_defaults()
        self.set("ssid", ssid)
        self.set("wpa_passphrase", passphrase)
        self.set("wpa", "3")
        self.set("wpa_key_mgmt", "WPA-PSK")
        self.set("wpa_pairwise", "TKIP")
        self.set("rsn_pairwise", "CCMP")

    def set_wep(self, ssid, key):
        self.set_defaults()
        self.set("ssid", ssid)
        self.set("wep_key0", key)

    def enable(self):
        if "OK" not in self.request("ENABLE"):
            raise Exception("Failed to enable hostapd interface " + self.ifname)

    def disable(self):
        if "OK" not in self.request("DISABLE"):
            raise Exception("Failed to disable hostapd interface " + self.ifname)

    def link_remove(self, count=10):
        if "OK" not in self.request("LINK_REMOVE %u" % count):
            raise Exception("Failed to remove hostapd link " + self.ifname)

    def dump_monitor(self):
        while self.mon.pending():
            ev = self.mon.recv()
            logger.debug(self.dbg + ": " + ev)

    def wait_event(self, events, timeout):
        if not isinstance(events, list):
            raise Exception(
                "Hostapd.wait_event() called with incorrect events argument type"
            )
        start = os.times()[4]
        while True:
            while self.mon.pending():
                ev = self.mon.recv()
                logger.debug(self.dbg + ": " + ev)
                for event in events:
                    if event in ev:
                        return ev
            now = os.times()[4]
            remaining = start + timeout - now
            if remaining <= 0:
                break
            if not self.mon.pending(timeout=remaining):
                break
        return None

    def wait_sta(self, addr=None, timeout=2, wait_4way_hs=False):
        ev = self.wait_event(["AP-STA-CONNECT"], timeout=timeout)
        if ev is None:
            raise Exception("AP did not report STA connection")
        if addr and addr not in ev:
            raise Exception("Unexpected STA address in connection event: " + ev)
        if wait_4way_hs:
            ev2 = self.wait_event(["EAPOL-4WAY-HS-COMPLETED"], timeout=timeout)
            if ev2 is None:
                raise Exception("AP did not report 4-way handshake completion")
            if addr and addr not in ev2:
                raise Exception(
                    "Unexpected STA address in 4-way handshake completion event: " + ev2
                )
        return ev

    def wait_sta_disconnect(self, addr=None, timeout=2):
        ev = self.wait_event(["AP-STA-DISCONNECT"], timeout=timeout)
        if ev is None:
            raise Exception("AP did not report STA disconnection")
        if addr and addr not in ev:
            raise Exception("Unexpected STA address in disconnection event: " + ev)
        return ev

    def wait_4way_hs(self, addr=None, timeout=1):
        ev = self.wait_event(["EAPOL-4WAY-HS-COMPLETED"], timeout=timeout)
        if ev is None:
            raise Exception("hostapd did not report 4-way handshake completion")
        if addr and addr not in ev:
            raise Exception(
                "Unexpected STA address in 4-way handshake completion event: " + ev
            )
        return ev

    def wait_ptkinitdone(self, addr, timeout=2):
        while timeout > 0:
            sta = self.get_sta(addr)
            if "hostapdWPAPTKState" not in sta:
                raise Exception("GET_STA did not return hostapdWPAPTKState")
            state = sta["hostapdWPAPTKState"]
            if state == "11":
                return
            time.sleep(0.1)
            timeout -= 0.1
        raise Exception("Timeout while waiting for PTKINITDONE")

    def get_status(self):
        res = self.request("STATUS")
        lines = res.splitlines()
        vals = dict()
        for line in lines:
            [name, value] = line.split("=", 1)
            vals[name] = value
        return vals

    def get_status_field(self, field):
        vals = self.get_status()
        if field in vals:
            return vals[field]
        return None

    def get_driver_status(self):
        res = self.request("STATUS-DRIVER")
        lines = res.splitlines()
        vals = dict()
        for line in lines:
            [name, value] = line.split("=", 1)
            vals[name] = value
        return vals

    def get_driver_status_field(self, field):
        vals = self.get_driver_status()
        if field in vals:
            return vals[field]
        return None

    def get_config(self):
        res = self.request("GET_CONFIG")
        lines = res.splitlines()
        vals = dict()
        for line in lines:
            [name, value] = line.split("=", 1)
            vals[name] = value
        return vals

    def mgmt_rx(self, timeout=5):
        ev = self.wait_event(["MGMT-RX"], timeout=timeout)
        if ev is None:
            return None
        msg = {}
        frame = binascii.unhexlify(ev.split(" ")[1])
        msg["frame"] = frame

        hdr = struct.unpack("<HH6B6B6BH", frame[0:24])
        msg["fc"] = hdr[0]
        msg["subtype"] = (hdr[0] >> 4) & 0xF
        hdr = hdr[1:]
        msg["duration"] = hdr[0]
        hdr = hdr[1:]
        msg["da"] = "%02x:%02x:%02x:%02x:%02x:%02x" % hdr[0:6]
        hdr = hdr[6:]
        msg["sa"] = "%02x:%02x:%02x:%02x:%02x:%02x" % hdr[0:6]
        hdr = hdr[6:]
        msg["bssid"] = "%02x:%02x:%02x:%02x:%02x:%02x" % hdr[0:6]
        hdr = hdr[6:]
        msg["seq_ctrl"] = hdr[0]
        msg["payload"] = frame[24:]

        return msg

    def mgmt_tx(self, msg):
        t = (
            (msg["fc"], 0)
            + mac2tuple(msg["da"])
            + mac2tuple(msg["sa"])
            + mac2tuple(msg["bssid"])
            + (0,)
        )
        hdr = struct.pack("<HH6B6B6BH", *t)
        res = self.request("MGMT_TX " + binascii.hexlify(hdr + msg["payload"]).decode())
        if "OK" not in res:
            raise Exception("MGMT_TX command to hostapd failed")

    def get_sta(self, addr, info=None, next=False):
        cmd = "STA-NEXT " if next else "STA "
        if addr is None:
            res = self.request("STA-FIRST")
        elif info:
            res = self.request(cmd + addr + " " + info)
        else:
            res = self.request(cmd + addr)
        lines = res.splitlines()
        vals = dict()
        first = True
        for line in lines:
            if first and "=" not in line:
                vals["addr"] = line
                first = False
            else:
                [name, value] = line.split("=", 1)
                vals[name] = value
        return vals

    def get_mib(self, param=None):
        if param:
            res = self.request("MIB " + param)
        else:
            res = self.request("MIB")
        lines = res.splitlines()
        vals = dict()
        for line in lines:
            name_val = line.split("=", 1)
            if len(name_val) > 1:
                vals[name_val[0]] = name_val[1]
        return vals

    def get_pmksa(self, addr):
        res = self.request("PMKSA")
        lines = res.splitlines()
        for line in lines:
            if addr not in line:
                continue
            vals = dict()
            [index, aa, pmkid, expiration, opportunistic] = line.split(" ")
            vals["index"] = index
            vals["pmkid"] = pmkid
            vals["expiration"] = expiration
            vals["opportunistic"] = opportunistic
            return vals
        return None

    def dpp_qr_code(self, uri):
        res = self.request("DPP_QR_CODE " + uri)
        if "FAIL" in res:
            raise Exception("Failed to parse QR Code URI")
        return int(res)

    def dpp_nfc_uri(self, uri):
        res = self.request("DPP_NFC_URI " + uri)
        if "FAIL" in res:
            raise Exception("Failed to parse NFC URI")
        return int(res)

    def dpp_bootstrap_gen(
        self,
        type="qrcode",
        chan=None,
        mac=None,
        info=None,
        curve=None,
        key=None,
        supported_curves=None,
        host=None,
    ):
        cmd = "DPP_BOOTSTRAP_GEN type=" + type
        if chan:
            cmd += " chan=" + chan
        if mac:
            if mac is True:
                mac = self.own_addr()
            cmd += " mac=" + mac.replace(":", "")
        if info:
            cmd += " info=" + info
        if curve:
            cmd += " curve=" + curve
        if key:
            cmd += " key=" + key
        if supported_curves:
            cmd += " supported_curves=" + supported_curves
        if host:
            cmd += " host=" + host
        res = self.request(cmd)
        if "FAIL" in res:
            raise Exception("Failed to generate bootstrapping info")
        return int(res)

    def dpp_bootstrap_set(
        self, id, conf=None, configurator=None, ssid=None, extra=None
    ):
        cmd = "DPP_BOOTSTRAP_SET %d" % id
        if ssid:
            cmd += " ssid=" + binascii.hexlify(ssid.encode()).decode()
        if extra:
            cmd += " " + extra
        if conf:
            cmd += " conf=" + conf
        if configurator is not None:
            cmd += " configurator=%d" % configurator
        if "OK" not in self.request(cmd):
            raise Exception("Failed to set bootstrapping parameters")

    def dpp_listen(self, freq, netrole=None, qr=None, role=None):
        cmd = "DPP_LISTEN " + str(freq)
        if netrole:
            cmd += " netrole=" + netrole
        if qr:
            cmd += " qr=" + qr
        if role:
            cmd += " role=" + role
        if "OK" not in self.request(cmd):
            raise Exception("Failed to start listen operation")

    def dpp_auth_init(
        self,
        peer=None,
        uri=None,
        conf=None,
        configurator=None,
        extra=None,
        own=None,
        role=None,
        neg_freq=None,
        ssid=None,
        passphrase=None,
        expect_fail=False,
        conn_status=False,
        nfc_uri=None,
    ):
        cmd = "DPP_AUTH_INIT"
        if peer is None:
            if nfc_uri:
                peer = self.dpp_nfc_uri(nfc_uri)
            else:
                peer = self.dpp_qr_code(uri)
        cmd += " peer=%d" % peer
        if own is not None:
            cmd += " own=%d" % own
        if role:
            cmd += " role=" + role
        if extra:
            cmd += " " + extra
        if conf:
            cmd += " conf=" + conf
        if configurator is not None:
            cmd += " configurator=%d" % configurator
        if neg_freq:
            cmd += " neg_freq=%d" % neg_freq
        if ssid:
            cmd += " ssid=" + binascii.hexlify(ssid.encode()).decode()
        if passphrase:
            cmd += " pass=" + binascii.hexlify(passphrase.encode()).decode()
        if conn_status:
            cmd += " conn_status=1"
        res = self.request(cmd)
        if expect_fail:
            if "FAIL" not in res:
                raise Exception("DPP authentication started unexpectedly")
            return
        if "OK" not in res:
            raise Exception("Failed to initiate DPP Authentication")

    def dpp_pkex_init(
        self,
        identifier,
        code,
        role=None,
        key=None,
        curve=None,
        extra=None,
        use_id=None,
        ver=None,
    ):
        if use_id is None:
            id1 = self.dpp_bootstrap_gen(type="pkex", key=key, curve=curve)
        else:
            id1 = use_id
        cmd = "own=%d " % id1
        if identifier:
            cmd += "identifier=%s " % identifier
        cmd += "init=1 "
        if ver is not None:
            cmd += "ver=" + str(ver) + " "
        if role:
            cmd += "role=%s " % role
        if extra:
            cmd += extra + " "
        cmd += "code=%s" % code
        res = self.request("DPP_PKEX_ADD " + cmd)
        if "FAIL" in res:
            raise Exception("Failed to set PKEX data (initiator)")
        return id1

    def dpp_pkex_resp(
        self, freq, identifier, code, key=None, curve=None, listen_role=None
    ):
        id0 = self.dpp_bootstrap_gen(type="pkex", key=key, curve=curve)
        cmd = "own=%d " % id0
        if identifier:
            cmd += "identifier=%s " % identifier
        cmd += "code=%s" % code
        res = self.request("DPP_PKEX_ADD " + cmd)
        if "FAIL" in res:
            raise Exception("Failed to set PKEX data (responder)")
        self.dpp_listen(freq, role=listen_role)

    def dpp_configurator_add(self, curve=None, key=None, net_access_key_curve=None):
        cmd = "DPP_CONFIGURATOR_ADD"
        if curve:
            cmd += " curve=" + curve
        if net_access_key_curve:
            cmd += " net_access_key_curve=" + curve
        if key:
            cmd += " key=" + key
        res = self.request(cmd)
        if "FAIL" in res:
            raise Exception("Failed to add configurator")
        return int(res)

    def dpp_configurator_remove(self, conf_id):
        res = self.request("DPP_CONFIGURATOR_REMOVE %d" % conf_id)
        if "OK" not in res:
            raise Exception("DPP_CONFIGURATOR_REMOVE failed")

    def note(self, txt):
        self.request("NOTE " + txt)

    def send_file(self, src, dst):
        self.host.send_file(src, dst)

    def get_ptksa(self, bssid, cipher):
        res = self.request("PTKSA_CACHE_LIST")
        lines = res.splitlines()
        for line in lines:
            if bssid not in line or cipher not in line:
                continue
            vals = dict()
            [index, addr, cipher, expiration, tk, kdk] = line.split(" ", 5)
            vals["index"] = index
            vals["addr"] = addr
            vals["cipher"] = cipher
            vals["expiration"] = expiration
            vals["tk"] = tk
            vals["kdk"] = kdk
            return vals
        return None
