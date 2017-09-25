import './styles/style.scss';
import Elm from './Main.elm';

const div = document.getElementById('app');
window.main = Elm.Main.embed(div);
