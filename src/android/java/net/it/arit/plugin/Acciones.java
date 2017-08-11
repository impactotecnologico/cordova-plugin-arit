package net.it.arit.plugin;

public enum Acciones {
        MENU(1),
        BIENVENIDA(2);

        private int accion;

        Acciones(int accion) {
            this.accion = accion;
        }

        public int accion() {
            return accion;
        }
    }
