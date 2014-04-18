using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace photo_wall
{
    class DummyEndpoint
    {
        public DummyEndpoint(EventHandler.EventTypes type, EventHandler e) {
            this.handler = e;
            return;
        }
        private EventHandler handler;
    }
}
