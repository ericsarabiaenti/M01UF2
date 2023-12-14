#!/bin/bash

#borrar todas las reglas de iptables
iptables -F

#aplicar las politicas restrictivas
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

#aceptar SOLO nuestra máquina
iptables -A INPUT -s 10.65.0.68 -j ACCEPT
iptables -A INPUT -s 10.65.0.47 -j ACCEPT

iptables -A OUTPUT -d 10.65.0.68 -j ACCEPT
iptables -A OUTPUT -d 10.65.0.47 -j ACCEPT

#Aceptar solo el puerto 3333 y el 22
iptables -A INPUT -p tcp --dport 3333 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3333 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

