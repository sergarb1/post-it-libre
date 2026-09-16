# Post-it Libre

Widget de notas adhesivas para KDE Plasma 6. Notas movibles, redimensionables y personalizables directamente en el escritorio.

## Caracteristicas

- **Movimiento libre**: Arrastra la barra superior para mover la nota sin entrar en modo edicion
- **Redimensionar**: Arrastrar las esquinas o bordes para cambiar el tamano
- **Colapsar**: Boton +/- para ocultar/mostrar el area de texto
- **Markdown**: Soporte nativo con toggle on/off
- **Formato de texto**: Negrita (Ctrl+B), Cursiva (Ctrl+I), Subrayado (Ctrl+U)
- **Fuentes**: Seleccion de familia de fuente y tamano (8-72)
- **Colores**: 9 colores predefinidos (amarillo, rosa, verde, azul, naranja, morado, cyan, gris, blanco)
- **Transparencia**: Slider ajustable del 20% al 100%
- **Persistencia**: Todo se guarda automaticamente (texto, color, tamano, fuente, etc.)

## Requisitos

- KDE Plasma 6
- Qt 6
- qml6-module-org-kde-plasma

## Instalacion manual

```bash
git clone https://github.com/sergarb1/post-it-libre.git
cd post-it-libre/mis-notas-postit
kpackagetool6 -t Plasma/Applet -i .
```

Para actualizar despues de cambios:
```bash
kpackagetool6 -t Plasma/Applet -u .
```

Para desinstalar:
```bash
kpackagetool6 -t Plasma/Applet -r org.usuario.misnotas
```

Despues de instalar, reinicia Plasmashell:
```bash
plasmashell --replace &
```

Busca "Post-it Libre" en la lista de widgets del escritorio.

## Estructura

```
mis-notas-postit/
├── metadata.json
└── contents/
    ├── config/
    │   ├── main.xml
    │   ├── config.qml
    │   └── configAppearance.qml
    └── ui/
        └── main.qml
```

## Licencia

AGPL-3.0-or-later
