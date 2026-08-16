import sys
import re
import os

STUB_METHOD = '''\
    .locals 1
    const/4 v0, 0x%s
    return v0
'''

STUB_VOID = '''\
    .locals 0
    return-void
'''

def main():
    if len(sys.argv) < 2:
        print("No input file")
        return 1

    smali_path = sys.argv[1]
    method_body = None
    method_name_to_patch = None
    method_set = set()

    # Determine if we have custom body parameters
    if "-m" in sys.argv:
        m_idx = sys.argv.index("-m")
        if m_idx + 1 < len(sys.argv):
            body_file = sys.argv[m_idx + 1]
            if os.path.isfile(body_file):
                with open(body_file, 'r', encoding='utf-8') as f:
                    method_body = f.read()
            else:
                print(f"----> Method body file not found: {body_file}")
                return 1
        # Extract the method name (usually the argument before or after the flags)
        remaining = [arg for i, arg in enumerate(sys.argv[2:]) if i != (m_idx - 2) and i != (m_idx - 1)]
        if remaining:
            method_name_to_patch = remaining[0]
            
    elif "-body" in sys.argv:
        body_idx = sys.argv.index("-body")
        if body_idx + 1 < len(sys.argv):
            method_body = sys.argv[body_idx + 1]
        remaining = [arg for i, arg in enumerate(sys.argv[2:]) if i != (body_idx - 2) and i != (body_idx - 1)]
        if remaining:
            method_name_to_patch = remaining[0]
            
    elif len(sys.argv) == 4 and not sys.argv[2].startswith('-') and not sys.argv[3].startswith('-'):
        # Usage: python3 patchmethod.py <smali_file> <method_name> <body_string>
        method_name_to_patch = sys.argv[2]
        method_body = sys.argv[3]
        
    else:
        # Legacy list mode: e.g. python3 patchmethod.py file.smali method1 -method2 --method3
        method_list = sys.argv[2:]
        if len(method_list) == 0:
            return 0
        method_set = set(method_list)

    if method_body is not None:
        try:
            # Unescape backslash-escaped characters (like \n, \t) for CLI strings
            if "-m" not in sys.argv:
                method_body = method_body.encode('utf-8').decode('unicode_escape')
        except Exception:
            pass

    if not os.path.isfile(smali_path):
        print("----> Ignore patch: \"%s\" not found" % os.path.basename(smali_path))
        return 0

    with open(smali_path, 'r', encoding='utf-8') as f:
        smali = f.read()

    patched = ''
    overwriting = False
    overvalue = None

    for line in smali.splitlines():
        # Robust regex matching that supports final, static, public, private, synthetic, etc.
        method_line = re.search(r'\.method\s+.*?(?:([a-zA-Z0-9_\$<>]+))\s*\(', line)
        if method_line:
            method_name = method_line.group(1)
            # Check if this method is the one we want to patch
            if method_name_to_patch is not None and method_name == method_name_to_patch:
                overwriting = True
                overvalue = method_body
            elif method_set:
                if method_name in method_set:
                    overwriting = True
                    overvalue = '1'
                elif ('-' + method_name) in method_set:
                    overwriting = True
                    overvalue = '0'
                elif ('--' + method_name) in method_set:
                    overwriting = True
                    overvalue = '-1'
            patched += line + '\n'
        elif '.end method' in line:
            if overwriting:
                overwriting = False
                if method_name_to_patch is not None:
                    patched += overvalue.rstrip('\r\n') + '\n' + line + '\n'
                    print(f"----> patched method: {method_name_to_patch} => custom body")
                else:
                    if overvalue == '-1':
                        patched += STUB_VOID + line + '\n'
                        print('----> patched method: ' + method_name + ' => void')
                    else:
                        patched += (STUB_METHOD % overvalue) + line + '\n'
                        print('----> patched method: ' + method_name + \
                              ' => ' + ('true' if overvalue == '1' else 'false'))
            else:
                patched += line + '\n'
        else:
            if not overwriting:
                patched += line + '\n'

    with open(smali_path, 'w', encoding='utf-8') as f:
        f.write(patched)

if __name__ == "__main__":
    main()
