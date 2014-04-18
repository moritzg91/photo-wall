using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace photo_wall
{
    class EventHandler
    {
        enum EventTypes {
            Event_A,
            Event_B
        };
        delegate void KinectEvent(EventTypes type);
        public event KinectEvent gestureEvent;

        // add event handler (callback fn)
        this.gestureEvent += new KinectEvent(this,callback_fn);

    }
}
