#!/bin/bash

# emba - EMBEDDED LINUX ANALYZER
#
# Copyright 2020 Siemens Energy AG
#
# emba comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
# welcome to redistribute it under the terms of the GNU General Public License.
# See LICENSE file for usage of this software.
#
# emba is licensed under GPLv3
#
# Author(s): Michael Messner, Pascal Eckmann

P09_firmware_base_version_check() {

  module_log_init "${FUNCNAME[0]}"
  module_title "Binary firmware versions detection"

  declare -a VERSIONS_DETECTED

  print_output "[*] Initial version detection running " | tr -d "\n"
  while read -r VERSION_LINE; do
    print_output "." | tr -d "\n"

    VERSION_IDENTIFIER="$(echo "$VERSION_LINE" | cut -d: -f2- | sed s/^\"// | sed s/\"$//)"
    print_output "." | tr -d "\n"

    # currently we only have binwalk files but sometimes we can find kernel version information or something else in it
    VERSION_FINDER=$(find "$LOG_DIR"/*.txt -type f -exec grep -o -a -e "$VERSION_IDENTIFIER" {} \;| head -1 2> /dev/null)
    VERSIONS_DETECTED+=("$VERSION_FINDER")
    print_output "." | tr -d "\n"

    VERSION_FINDER=$(find "$OUTPUT_DIR" -type f -exec strings {} \; | grep -o -a -e "$VERSION_IDENTIFIER" | head -1 2> /dev/null)
    VERSIONS_DETECTED+=("$VERSION_FINDER")
    print_output "." | tr -d "\n"

    VERSION_FINDER=$(find "$FIRMWARE_PATH" -type f -exec strings {} \; | grep -o -a -e "$VERSION_IDENTIFIER" | head -1 2> /dev/null)
    VERSIONS_DETECTED+=("$VERSION_FINDER")
    # leave it here for backup reasons:
    #VERSION_STRINGER=$(strings "$FIRMWARE_PATH" | grep -H -o -a -e "$VERSION_IDENTIFIER" | head -1 2> /dev/null)
    print_output "." | tr -d "\n"

  done  < "$CONFIG_DIR"/bin_version_strings.cfg
  print_output "." | tr -d "\n"

  echo
  for VERSION_LINE in "${VERSIONS_DETECTED[@]}"; do
    if [[ -n $VERSION_LINE ]]; then
      if [ "$VERSION_LINE" != "$VERS_LINE_OLD" ]; then
        VERS_LINE_OLD="$VERSION_LINE"
        #future extension:
        #BINARY="$(basename $(echo "$VERSION_LINE" | cut -d: -f1))"
        print_output "[+] Version information found ${RED}""$VERSION_LINE""${NC}${GREEN} in firmware blob."
      fi
    fi
  done
  export TESTING_DONE=1
}
