import Toybox.Lang;

module MonkeyHooks {
    var _globalStore as Store? = null;

    function getStore() as Store {
        if (_globalStore == null) {
            _globalStore = new Store();
        }
        return _globalStore as Store;
    }

    function useArena(key as Object) as Context {
        return new Context(getStore(), key);
    }
    function destroy(key as Object) as Void {
        getStore().destroy(key);
    }
}
