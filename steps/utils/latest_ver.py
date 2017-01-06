
import urllib.request
import re

def main():
    resp = urllib.request.urlopen("https://archive.archlinux.org/iso/")
    body = resp.read().decode('utf-8')
    
    redate = re.compile("20[0-9]{2}[.][0-9]{2}[.][0-9]{2}")
    versions = [m.group() for m in redate.finditer(body)]
    versions.sort()
    print(versions[-1])
    return True

if __name__ == '__main__':
    import sys
    sys.exit(0 if main() else 1)
