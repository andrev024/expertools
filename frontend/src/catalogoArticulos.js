// Catalogo de referencia para el formulario de "articulo nuevo".
// Para agregar/quitar un tipo, marca o modelo, edita este objeto --
// no hace falta tocar el backend ni la base de datos.
//
// Estructura: { Tipo: { Marca: [Modelos...] } }
// Ajusta esto con las herramientas y marcas REALES que maneja la tienda.

export const CATALOGO_ARTICULOS = {
  Taladro: {
    DeWalt: ['DW505', 'DW511', 'DCD778', 'DCD709', 'DWD024'],
    Bosch: ['GSB 13 RE', 'GSB 21-2', 'GSR 120-LI', 'GBM 350'],
    Makita: ['HP1630', 'HP2050', 'DHP484', 'M6100'],
    Truper: ['ROTM-1/2', 'TALP-3/8', 'TALB-500'],
    Total: ['TD1076116', 'TD2081026'],
    'Black+Decker': ['HD500', 'KR504', 'BEH820'],
  },
  'Rotomartillo / Taladro percutor': {
    Bosch: ['GBH 2-20', 'GBH 2-26', 'GBH 5-40'],
    Makita: ['HR2470', 'HR2630', 'HR4013C'],
    DeWalt: ['D25133', 'D25263K'],
    Truper: ['ROTP-1/2', 'ROTP-5/8'],
  },
  'Pulidora / Esmeriladora angular': {
    Makita: ['9557NB', 'PC5000C', 'GA9020', '9558HN'],
    Bosch: ['GWS 8-100', 'GWS 22-180', 'GWS 850'],
    DeWalt: ['DWE4120', 'DWE4899', 'DWE402'],
    Truper: ['ESME-4 1/2', 'ESME-7'],
    Total: ['TG1091162'],
  },
  'Sierra circular': {
    DeWalt: ['DWE575', 'DWE7491', 'DWE560'],
    Makita: ['5007NB', '5477NB', 'HS0600'],
    Bosch: ['GKS 190', 'GKS 235'],
    Truper: ['SIEC-7 1/4'],
  },
  'Sierra caladora': {
    Bosch: ['GST 650', 'GST 8000E'],
    Makita: ['4329', '4351FCT'],
    DeWalt: ['DW331K'],
    Total: ['TS2071856'],
  },
  'Sierra ingletadora': {
    DeWalt: ['DW713', 'DWS716'],
    Makita: ['LS1040', 'LS0714'],
    Bosch: ['GCM 10'],
  },
  Compresor: {
    Truper: ['COMP-25', 'COMP-50', 'COMP-100L'],
    Campbell: ['VT6180', 'HS5180'],
    Stanley: ['SXCM1503HE'],
    Total: ['TA1090116'],
  },
  Soldador: {
    Lincoln: ['AC225', 'Invertec V160'],
    Infra: ['INVERTIG 200', 'ARC 160'],
    Truper: ['SOLD-140', 'SOLD-200'],
  },
  Motobomba: {
    Honda: ['WB20XT', 'WB30XT'],
    Truper: ['MOTO-2', 'MOTO-3'],
    Total: ['TP1500'],
  },
  'Guadaña / Desmalezadora': {
    Stihl: ['FS 55', 'FS 220', 'FS 380'],
    Husqvarna: ['128R', '525RX'],
    Truper: ['DESB-52', 'DESB-43'],
  },
  Motosierra: {
    Stihl: ['MS 170', 'MS 250', 'MS 382'],
    Husqvarna: ['135', '450', '562XP'],
    Truper: ['MOTOS-16', 'MOTOS-18'],
  },
  'Generador eléctrico': {
    Honda: ['EU22i', 'EU30is', 'EG5000'],
    Truper: ['GEN-3000', 'GEN-5500'],
    Total: ['TP-GEN2500'],
  },
  Multiherramienta: {
    Bosch: ['GOP 40-30', 'PMF 250 CES'],
    DeWalt: ['DWE315', 'DCS355'],
    Makita: ['TM3010CX3'],
  },
  'Atornillador de impacto': {
    DeWalt: ['DCF887', 'DCF850'],
    Makita: ['DTW285', 'TW1000'],
    Bosch: ['GDR 120-LI'],
  },
  Lijadora: {
    Makita: ['BO5041', '9403'],
    Bosch: ['GSS 23AE', 'GBS 75AE'],
    DeWalt: ['DWE6423', 'DWP849X'],
  },
  'Pistola de calor': {
    Bosch: ['GHG 20-63'],
    Truper: ['PIST-1500'],
    Total: ['TH2018'],
  },
};

// Lista de tipos disponibles (las "llaves" del catalogo), mas la opcion "Otro"
export const TIPOS_DISPONIBLES = [...Object.keys(CATALOGO_ARTICULOS), 'Otro'];
