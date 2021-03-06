#!/bin/bash
echo "# -------------------------------------------"
echo "# A CentOS 7.0 x64 deployment script to      "
echo "# configure firewalld                        "
echo "#                                            "
echo "# Author : Keegan Mullaney                   "
echo "# Company: KM Authorized LLC                 "
echo "# Website: http://kmauthorized.com           "
echo "#                                            "
echo "# MIT: http://kma.mit-license.org            "
echo "# -------------------------------------------"

# status
if [ $(systemctl is-active firewalld) != "active" ]; then
   systemctl start firewalld
   systemctl enable firewalld
   echo "started firewalld and set to run at server boot"
fi
pause "Press enter to check the current status of firewalld..."
systemctl status firewalld

# zones
echo
echo "default zone: "
DEFAULT_ZONE=$(firewall-cmd --get-default-zone)
echo "$DEFAULT_ZONE"
pause
echo
echo "active zones: "
ACTIVE_ZONES=$(firewall-cmd --get-active-zones)
echo "$ACTIVE_ZONES"
pause
echo
echo "available zones: "
AVAILABLE_ZONES=$(firewall-cmd --get-zones)
echo "$AVAILABLE_ZONES"

echo
pause "Press enter to configure firewalld..."

# collect user inputs to determine which zone to set as default
echo
echo "Which zone would you like to set as default?"
select zone in $AVAILABLE_ZONES; do
   DEFAULT_ZONE="$zone"
   break
done

# set default zone
if echo "$ACTIVE_ZONES" | grep -qw "$DEFAULT_ZONE"; then
   echo "The default zone is already set."
else
   firewall-cmd --set-default-zone=$DEFAULT_ZONE && echo "Zone \"$DEFAULT_ZONE\" was set as default"
fi

# remove trusted hosts from other zones
echo
pause "Press enter to initialize trusted hosts..."
ALL_HOSTS="$TRUSTED_IPV4_HOSTS \
$TRUSTED_IPV6_HOSTS"
for zone in $AVAILABLE_ZONES; do
   ZONE_HOSTS=$(firewall-cmd --zone=$zone --list-sources)
   for s in $ZONE_HOSTS; do
      if echo $ALL_HOSTS | grep -qw $s; then
         firewall-cmd --zone=$zone --remove-source=$s --permanent
         echo "removed source: \"$s\" from zone \"$zone\""
      else
         echo "source: \"$s\" not removed from zone \"$zone\""
      fi
   done
done

# remove existing services from default zone
echo
pause "Press enter to initialize default services..."
DEFAULT_SERVICES=$(firewall-cmd --list-services)
for svc in $DEFAULT_SERVICES; do
   echo "Would you like to keep \"$svc\" in zone \"$DEFAULT_ZONE\"?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") break;;
          "No") firewall-cmd --remove-service=$svc --permanent
                echo "removed service: \"$svc\" from zone \"$DEFAULT_ZONE\"";;
             *) echo "case not found..."
                continue;;
      esac
      break
   done
done

# add trusted IPv4 hosts
echo
pause "Press enter to add trusted IPv4 hosts..."
for s in $TRUSTED_IPV4_HOSTS; do
   firewall-cmd --add-source=$s --permanent
   echo "added host: $s"
done

# add trusted IPv6 hosts
echo
pause "Press enter to add trusted IPv6 hosts..."
for s in $TRUSTED_IPV6_HOSTS; do
   firewall-cmd --add-source=$s --permanent
   echo "added host: $s"
done

if $CLOUDFLARE_GO; then
   # add trusted Cloudflare IPv4 hosts
   echo
   pause "Press enter to add trusted Cloudflare IPv4 hosts..."
   for s in $CLOUDFLARE_IPV4_HOSTS; do
      firewall-cmd --add-source=$s --permanent
      echo "added host: $s"
   done

   # add trusted Cloudflare IPv6 hosts
   echo
   pause "Press enter to add trusted Cloudflare IPv6 hosts..."
   for s in $CLOUDFLARE_IPV6_HOSTS; do
      firewall-cmd --add-source=$s --permanent
      echo "added host: $s"
   done
fi

# what we allow from Internet - services
echo
pause "Press enter to add services..."
for s in $SERVICES; do
   firewall-cmd --add-service=$s --permanent
   echo "added service: $s"
done

# what we allow from Internet - TCP ports
echo
pause "Press enter to add TCP ports..."
for p in $TCP_PORTS; do
   firewall-cmd --add-port=$p/tcp --permanent
   echo "added port: $p"
done

# what we allow from Internet - UDP ports
echo
pause "Press enter to add UDP ports..."
for p in $UDP_PORTS; do
   firewall-cmd --add-port=$p/udp --permanent
   echo "added port: $p"
done

# restart the firewall without stopping current connections
echo
pause "Press enter to reload the firewall..."
firewall-cmd --reload

# list the zone info
echo
pause "Press enter to list the details for zone: ${DEFAULT_ZONE}"
firewall-cmd --list-all
