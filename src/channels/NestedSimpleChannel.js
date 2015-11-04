import * as Directions from '../Directions';

import UnidirectionalChannel from './UnidirectionalChannel';
import defineNodeSource from './defineNodeSource';
import defineChannelTarget from './defineChannelTarget';


export default class NestedSimpleChannel extends UnidirectionalChannel {}

defineNodeSource(NestedSimpleChannel.prototype);
defineChannelTarget(NestedSimpleChannel.prototype);

Object.defineProperty(
  NestedSimpleChannel.prototype, '_direction', {
    get() { return Directions.omni; },
  });
