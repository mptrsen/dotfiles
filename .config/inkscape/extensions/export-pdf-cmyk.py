# -*- coding: utf-8 -*-
#!/usr/bin/env python

#  Copyright (C) 2010, 2011 Jonatã Bolzan <jonata@jonata.org>
#  Copyright (C) 2011  Anton Katsarov <anton@katsarov.org>
#
#  This file is part of Export-PDF-CMYK.
#
#  Export-PDF-CMYK is free software: you
#  can redistribute it and/or modify it under the terms of the GNU
#  General Public License (GNU GPL) as published by the Free Software
#  Foundation, either version 3 of the License, or (at your option)
#  any later version.  The code is distributed WITHOUT ANY WARRANTY
#  without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU GPL for more details.
#
#  As additional permission under GNU GPL version 3 section 7, you
#  may distribute non-source (e.g., minimized or compacted) forms of
#  that code without the copy of the GNU GPL normally required by
#  section 4, provided you include this license notice and a URL
#  through which recipients can access the Corresponding Source.
#
#  END OF LICENSE HEADER

# These two lines are only needed if you don't put the script directly into
# the installation directory
import sys
reload(sys)
sys.setdefaultencoding("utf-8")
sys.path.append('/usr/share/inkscape/extensions')

import inkex, simplestyle, tempfile, os, re, subprocess

from lxml import etree

class ExportTIFF(inkex.Effect):
    def __init__(self):
        inkex.Effect.__init__(self)
        self.OptionParser.add_option("-c", "--specialeffects", action="store", type="inkbool", dest="specialeffects", default=True, help="Rasterize filter effects")
        self.OptionParser.add_option("-e", "--specialeffects_exclusively", action="store", type="inkbool", dest="specialeffects_exclusively", default=True, help="Hide all except selected")
        self.OptionParser.add_option("-r", "--resolution", action="store", type="int", dest="resolution", default=300, help="Resolution for rasterization (dpi)")
        self.OptionParser.add_option("-k", "--set_overprint_black", action="store", type="inkbool", dest="set_overprint_black", default=True, help="Preserve black")
        self.OptionParser.add_option("-i", "--icc_profile", action="store", type="inkbool", dest="icc_profile", default=True, help="ICC Profile")

    def output(self):
        out = open(tempfile.gettempdir() + os.sep + 'final.pdf','rb')
        if os.name == 'nt':
            try:
                import msvcrt
                msvcrt.setmode(1, os.O_BINARY)
            except:
                pass
        sys.stdout.write(out.read())
        out.close()

    def effect(self):
        svg = open(self.svg_file, 'r').read()

        def rename_svg_colors():
            #colortypes = ['fill', 'stop-color', 'flood-color', 'lighting-color', 'stroke']
            #for i in range(len(colortypes)):
            origin = svg
            for i in range(len(simplestyle.svgcolors.keys())):
                origin = str(origin).replace(':' + simplestyle.svgcolors.keys()[i] + ';', ':' + simplestyle.svgcolors[simplestyle.svgcolors.keys()[i]] + ';')
            return origin

        def what_export():
            doc = etree.parse(tempfile.gettempdir() + os.sep + 'final.svg')
            export_area = []
            list_of_effects = ["opacity:0", "filter", "Gradient", "image"]
            for i in range(len(list_of_effects)):
                for node in doc.getroot():
                    if not "<defs" in etree.tostring(node):
                        for child in node:
                            #open("/tmp/teste.txt", "w+").write(etree.tostring(child))
                            if list_of_effects[i] in etree.tostring(child):
                            #if 'style' in child.attrib and list_of_effects[i] in child.attrib['style']:
                                export_area.append(child.attrib['id'])
            return list(set(export_area))

        def calculateCMYK(red, green, blue):
            C = float()
            M = float()
            Y = float()
            K = float()

            if 1.00 - red < 1.00 - green:
                K = 1.00 - red
            else:
                K = 1.00 - green

            if 1.00 - blue < K:
                K = 1.00 - blue

            if K != 1.00:
                C = ( 1.00 - red   - K ) / ( 1.00 - K )
                M = ( 1.00 - green - K ) / ( 1.00 - K )
                Y = ( 1.00 - blue  - K ) / ( 1.00 - K )

            return [C, M, Y, K]

        def convert_elements_to_images():
            areas_to_export = what_export()

            file_svg_C = rename_svg_colors()
            file_svg_M = rename_svg_colors()
            file_svg_Y = rename_svg_colors()
            file_svg_K = rename_svg_colors()

            def removeK(origem):
                def zerar_opacidade(valor):
                    return str(valor.group()).split('opacity:')[0] + "opacity:0;"
                return re.sub("#000000;fill-opacity:[0-9.]+;", zerar_opacidade, re.sub("#000000;stop-opacity:[0-9.]+;", zerar_opacidade, re.sub("#000000;stroke-opacity:[0-9.]+;", zerar_opacidade, re.sub("#000000;flood-opacity:[0-9.]+;", zerar_opacidade, re.sub("#000000;lighting-opacity:[0-9.]+;", zerar_opacidade, origem)))))

            def representC(value):
                # returns CMS color if available
                if ( re.search("icc-color", value.group()) ):
                    return simplestyle.formatColor3f(float(1.00 - float(re.split('[,\)\s]+',value.group())[2])), float(1.00), float(1.00))

                red =   float(simplestyle.parseColor(str(value.group()))[0]/255.00)
                green = float(simplestyle.parseColor(str(value.group()))[1]/255.00)
                blue =  float(simplestyle.parseColor(str(value.group()))[2]/255.00)
                return simplestyle.formatColor3f(float(1.00 - calculateCMYK(red, green, blue)[0]), float(1.00), float(1.00))

            def representM(value):
        # returns CMS color if available
                if ( re.search("icc-color", value.group()) ):
                    return simplestyle.formatColor3f(float(1.00), float(1.00 - float(re.split('[,\)\s]+',value.group())[3])), float(1.00))

                red =   float(simplestyle.parseColor(str(value.group()))[0]/255.00)
                green = float(simplestyle.parseColor(str(value.group()))[1]/255.00)
                blue =  float(simplestyle.parseColor(str(value.group()))[2]/255.00)
                return simplestyle.formatColor3f(float(1.00), float(1.00 - calculateCMYK(red, green, blue)[1]), float(1.00))

            def representY(value):
        # returns CMS color if available
                if ( re.search("icc-color", value.group()) ):
                    return simplestyle.formatColor3f(float(1.00), float(1.00), float(1.00 - float(re.split('[,\)\s]+',value.group())[4])))

                red =   float(simplestyle.parseColor(str(value.group()))[0]/255.00)
                green = float(simplestyle.parseColor(str(value.group()))[1]/255.00)
                blue =  float(simplestyle.parseColor(str(value.group()))[2]/255.00)
                return simplestyle.formatColor3f(float(1.00), float(1.00), float(1.00 - calculateCMYK(red, green, blue)[2]))

            def representK(value):
        # returns CMS color if available
                if ( re.search("icc-color", value.group()) ):
                    return simplestyle.formatColor3f(float(1.00 - float(re.split('[,\)\s]+',value.group())[5])), float(1.00 - float(re.split('[,\)\s]+',value.group())[5])), float(1.00 - float(re.split('[,\)\s]+',value.group())[5])))
  
                red =   float(simplestyle.parseColor(str(value.group()))[0]/255.00)
                green = float(simplestyle.parseColor(str(value.group()))[1]/255.00)
                blue =  float(simplestyle.parseColor(str(value.group()))[2]/255.00)
                return simplestyle.formatColor3f(float(1.00 - calculateCMYK(red, green, blue)[3]), float(1.00 - calculateCMYK(red, green, blue)[3]), float(1.00 - calculateCMYK(red, green, blue)[3]))

            if (self.options.set_overprint_black):
                open(tempfile.gettempdir() + os.sep + "separationC.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representC, removeK(file_svg_C)))
                open(tempfile.gettempdir() + os.sep + "separationM.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representM, removeK(file_svg_M)))
                open(tempfile.gettempdir() + os.sep + "separationY.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representY, removeK(file_svg_Y)))
                open(tempfile.gettempdir() + os.sep + "separationK.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representK, file_svg_K))
            else:
                open(tempfile.gettempdir() + os.sep + "separationC.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representC, file_svg_C))
                open(tempfile.gettempdir() + os.sep + "separationM.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representM, file_svg_M))
                open(tempfile.gettempdir() + os.sep + "separationY.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representY, file_svg_Y))
                open(tempfile.gettempdir() + os.sep + "separationK.svg","w").write(re.sub("#[a-fA-F0-9]{6}( icc-color\(.*?\))?", representK, file_svg_K))

            resolution = str(int(self.options.resolution))

            #if self.options.specialeffects_exclusively:
            #    areas_to_export_only = '--export-id-only'
            #else:
            areas_to_export_only = ''

            alpha = " --export-background=white "
            color_space = "CMYK"
            #area_a_exportar_tamanho = " -C "
            area_a_exportar_tamanho = " "

            def generate_pngs():
                string_inkscape_exec = ''
                for i in range(len(areas_to_export)):
                    string_inkscape_exec = string_inkscape_exec + tempfile.gettempdir() + os.sep + "separationC.svg" + " " + "--export-id=" + areas_to_export[i] + " " + areas_to_export_only + area_a_exportar_tamanho + alpha + " " + '--export-png=' + tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "C.png" + ' --export-dpi=' + resolution + "\n"
                    string_inkscape_exec = string_inkscape_exec + tempfile.gettempdir() + os.sep + "separationM.svg" + " " + "--export-id=" + areas_to_export[i] + " " + areas_to_export_only + area_a_exportar_tamanho + alpha + " " + '--export-png=' + tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "M.png" + ' --export-dpi=' + resolution + "\n"
                    string_inkscape_exec = string_inkscape_exec + tempfile.gettempdir() + os.sep + "separationY.svg" + " " + "--export-id=" + areas_to_export[i] + " " + areas_to_export_only + area_a_exportar_tamanho + alpha + " " + '--export-png=' + tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "Y.png" + ' --export-dpi=' + resolution + "\n"
                    string_inkscape_exec = string_inkscape_exec + tempfile.gettempdir() + os.sep + "separationK.svg" + " " + "--export-id=" + areas_to_export[i] + " " + areas_to_export_only + area_a_exportar_tamanho + alpha + " " + '--export-png=' + tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "K.png" + ' --export-dpi=' + resolution + "\n"
                return string_inkscape_exec

            inkscape_exec = subprocess.Popen(['inkscape -z --shell'], shell=True, stdout=open('/dev/null', 'w'), stderr=open('/dev/null', 'w'), stdin=subprocess.PIPE)# + ['>', '/dev/null'])
            inkscape_exec.communicate(input=generate_pngs())

            for i in range(len(areas_to_export)):
                subprocess.Popen(['convert', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "C.png", '-colorspace', 'CMYK', '-channel', 'C', '-separate', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "C.png"]).wait()
                subprocess.Popen(['convert', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "M.png", '-colorspace', 'CMYK', '-channel', 'M', '-separate', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "M.png"]).wait()
                subprocess.Popen(['convert', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "Y.png", '-colorspace', 'CMYK', '-channel', 'Y', '-separate', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "Y.png"]).wait()
                subprocess.Popen(['convert', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "K.png", '-colorspace', 'CMYK', '-channel', 'K', '-separate', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "K.png"]).wait()
                subprocess.Popen(['convert', tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "C.png", tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "M.png", tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "Y.png", tempfile.gettempdir() + os.sep + "separated" + areas_to_export[i] + "K.png", '-set', 'colorspace', 'CMYK', '-combine', tempfile.gettempdir() + os.sep + areas_to_export[i] + ".jpg"]).wait()
                if (self.options.icc_profile):
                    cmyk_profile = open(os.getenv("HOME") + '/.config/inkscape/preferences.xml', 'r').read().split('id="softproof"')[1].split('uri="')[1].split('" />')[0]
                    subprocess.Popen(['convert',  tempfile.gettempdir() + os.sep + areas_to_export[i] + ".jpg", '-profile', cmyk_profile, tempfile.gettempdir() + os.sep + areas_to_export[i] + ".jpg"]).wait()

        def prepare_svg_to_pdf():
            def replace_for_device():
                origem = rename_svg_colors()
                def represent(value):
                    red =   float(simplestyle.parseColor(str(value.group()))[0]/255.00)
                    green = float(simplestyle.parseColor(str(value.group()))[1]/255.00)
                    blue =  float(simplestyle.parseColor(str(value.group()))[2]/255.00)
                    return str(str(simplestyle.formatColor3f(red,green,blue)) + ' device-cmyk(' + str(calculateCMYK(red, green, blue)[0]) + ' ' + str(calculateCMYK(red, green, blue)[1]) + ' ' + str(calculateCMYK(red, green, blue)[2]) + ' ' + str(calculateCMYK(red, green, blue)[3]) + ')')

                return re.sub("#[a-fA-F0-9]{6}", represent, origem)

            final = replace_for_device()

            if self.options.specialeffects:
                open(tempfile.gettempdir() + os.sep + 'final.svg', 'w').write(final)
                doc = etree.parse(tempfile.gettempdir() + os.sep + 'final.svg')
                areas_de_bitmaps = what_export()
                if len(areas_de_bitmaps) > 0:
                    convert_elements_to_images()
                objects_info = os.popen('inkscape -S "' + tempfile.gettempdir() + os.sep + 'final.svg' + '"')
                objects_info_list = objects_info.read().split("\n")


                for node in doc.getroot():
                    for child in node:
                        for j in range(len(areas_de_bitmaps)):
                            if 'id' in child.attrib and areas_de_bitmaps[j] in child.attrib['id']:
                                newNode=etree.Element('image')
                                for i in range(len(objects_info_list)):
                                    if child.attrib['id'] in objects_info_list[i].split(',')[0]:
                                        newNode.set('x', objects_info_list[i].split(',')[1])
                                        newNode.set('y', objects_info_list[i].split(',')[2])
                                        newNode.set('id', "image" + child.attrib['id'])
                                        newNode.set('width' , objects_info_list[i].split(',')[3])
                                        newNode.set('height' , objects_info_list[i].split(',')[4])
                                newNode.set('xlink_href', "file:///tmp/" + child.attrib['id'] + '.jpg')
                                node.replace(child, newNode)

                parsed = open(tempfile.gettempdir() + os.sep + 'finalPDF.svg', 'w')
                origem = doc.write(parsed)
            else:
                open(tempfile.gettempdir() + os.sep + 'finalPDF.svg', 'w').write(final)

        prepare_svg_to_pdf()

        replace_xlink = open(tempfile.gettempdir() + os.sep + 'finalPDF.svg', 'r').read()
        replace_xlink = replace_xlink.replace('xlink_href', 'xlink:href')

        if "<text " in replace_xlink:
            replace_xlink = ''
            subprocess.Popen(['inkscape', '--verb=EditSelectAllInAllLayers','--verb=ObjectToPath','--verb=FileSave','--verb=FileClose', tempfile.gettempdir() + os.sep + 'finalPDF.svg']).wait()
            replace_xlink = open(tempfile.gettempdir() + os.sep + 'finalPDF.svg', 'r').read()

        replace_xlink = replace_xlink.replace('medium;', '12;')
        replace_spot = ''
        for i in range(len(replace_xlink.split('\n'))): #eu seu que essa solução é "feia", mas por enquanto é a que soube fazer. Pelo menos está funcionando :)
            if 'id="crop' in replace_xlink.split('\n')[i] or 'id="bleed' in replace_xlink.split('\n')[i]:
                replace_spot = replace_spot + replace_xlink.split('\n')[i].replace('device-cmyk(0.0 0.0 0.0 1.0);', 'device-cmyk(1.0 1.0 1.0 1.0);') + '\n'
            else:
                replace_spot = replace_spot + replace_xlink.split('\n')[i] + '\n'

        open(tempfile.gettempdir() + os.sep + 'finalPDF.svg', 'w').write(replace_spot)

        subprocess.Popen(['uniconvertor', tempfile.gettempdir() + os.sep + 'finalPDF.svg', tempfile.gettempdir() + os.sep + 'final.pdf']).wait()


if __name__ == '__main__':
    effect = ExportTIFF()
    effect.affect()
