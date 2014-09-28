--[[

Lua profiler - Copyright Pepperfish 2002,2003,2004

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to
do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
]]

-- Converted to Lua 5, a few improvements, and 
-- additional documentation by Tom Spilman 
-- ( tom@sickheadgames.com )
-- Additional corrections and tidying  by original author
-- Daniel Silverstone ( dsilvers@pepperfish.net )
--
-- Note that this requires os.clock(), debug.sethook(),
-- and debug.getinfo() or your equivalent replacements to
-- be available if this is an embedded application.
--


--
-- Example usage:
--
--  profiler = newProfiler()
--  profiler:start()
--
--  < call some functions that take time >
--
--  profiler:stop()
--
--  local outfile = io.open( "profile.txt", "w+" )
--  profiler:report( outfile )
--  outfile:close()
--


--
--	All profiler related stuff is stored in the top level table '_profiler'
--
_profiler = {}


--
-- newProfiler() creates a new profiler object for managing 
-- the profiler and storing state.  Note that only one profiler 
-- object can be executing at one time.
--
function newProfiler()
   local newprof = {}
   for k,v in _profiler do
      newprof[k] = v;
   end
   return newprof
end


--
-- This function starts the profiler.  It will do nothing
-- if this (or any other) profiler is already running.
--
function _profiler.start(self)
   if( _profiler.running ) then
      return
   end
   -- Start the profiler. This begins by setting up internal profiler state
   _profiler.running = self;
   self.rawstats = {}
   self.callstack = {}
   debug.sethook( _profiler_hook_wrapper, "cr" )
end


--
-- This function stops the profiler.  It will do nothing 
-- if a profiler is not running, and nothing if it isn't 
-- the currently running profiler.
--
function _profiler.stop(self)
   if( _profiler.running ~= self ) then
      return
   end
   -- Stop the profiler.
   debug.sethook( nil )
   _profiler.running = nil
end


--
-- Simple wrapper to handle the hook.  You should not
-- be calling this directly.
--
function _profiler_hook_wrapper(action)
   if( _profiler.running == nil ) then
      debug.sethook( nil );
   end
   _profiler.running:_internal_profile(action)
end


--
-- This is the main internal function of the profiler and should not be called except by the hook wrapper
--
function _profiler._internal_profile(self,action)
   -- First entry on the stack will be the hook wrapper, ensure this...
   if( debug.getinfo( 2, "n" ).name ~= "_profiler_hook_wrapper" ) then
      print("Profiler's internal profiler function called by: ",debug.getinfo( 2, "n" ).name )
      exit(1);
   end
   -- Since we can obtain the 'function' for the item we've had call us, we can use that...
   local caller_info = debug.getinfo( 3 );
   if( caller_info == nil ) then
      print "No caller_info";
      return
   end

   --SHG_LOG( "[_profiler._internal_profile] " .. ( caller_info.name or "<nil>" ) )

   -- Retrieve the most recent activation record...
   local latest_ar = nil;
   if( table.getn(self.callstack) > 0 ) then
      latest_ar = self.callstack[table.getn(self.callstack)];
   end

   -- Are we allowed to profile this function?
   local should_not_profile = 0
   for k,v in self.prevented_functions do
      if( k == caller_info.func ) then
	 should_not_profile = v
      end
   end
   -- Also check the top activation record...
   if( latest_ar ) then
      if( latest_ar.should_not_profile == 2 ) then
	 should_not_profile = 2
      end
   end

   -- Now then, are we in 'call' or 'return' ?
   -- print("Profile:", caller_info.name, "SNP:", should_not_profile, "Action:", action );

   if( action == "call" ) then
      -- Making a call...
      local this_ar = {}
      this_ar.should_not_profile = should_not_profile;
      this_ar.parent_ar = latest_ar
      this_ar.anon_child = 0
      this_ar.name_child = 0
      this_ar.children = {}
      this_ar.children_time = {}
      this_ar.clock_start = os.clock()
      -- Last thing to do on a call is to insert this onto the ar stack...
      table.insert( self.callstack, this_ar );
   else
      local this_ar = latest_ar;
      if( this_ar == nil ) then
	 return; -- No point in doing anything if there's no upper activation record
      end

      -- Right, calculate the time in this function...
      this_ar.clock_end = os.clock()
      this_ar.this_time = this_ar.clock_end - this_ar.clock_start

      -- Now, if we have a parent, update its call info...
      if( this_ar.parent_ar ) then
	 this_ar.parent_ar.children[caller_info.func] = (this_ar.parent_ar.children[caller_info.func] or 0) + 1;
	 this_ar.parent_ar.children_time[caller_info.func] = (this_ar.parent_ar.children_time[caller_info.func] or 0 ) + this_ar.this_time;
	 if( caller_info.name == nil ) then
	    this_ar.parent_ar.anon_child = this_ar.parent_ar.anon_child + this_ar.this_time
	 else
	    this_ar.parent_ar.name_child = this_ar.parent_ar.name_child + this_ar.this_time
	 end
      end
      -- Now if we're meant to record information about ourselves, do so...
      if( this_ar.should_not_profile == 0 ) then
	 local inforec = self:_get_func_rec(caller_info.func,1);
	 inforec.count = inforec.count + 1;
	 inforec.time = inforec.time + this_ar.this_time
	 inforec.anon_child_time = inforec.anon_child_time + this_ar.anon_child
	 inforec.name_child_time = inforec.name_child_time + this_ar.name_child
	 inforec.func_info = caller_info
	 for k,v in this_ar.children do
	    inforec.children[k] = (inforec.children[k] or 0) + v;
	    inforec.children_time[k] = (inforec.children_time[k] or 0) + this_ar.children_time[k];
	 end
      end

      -- Last thing to do on return is to drop the last activation record...
      table.remove( self.callstack, table.getn( self.callstack ) );
   end

end


--
-- This returns a (possibly empty) function record for 
-- the specified function. It is for internal profiler use.
--
function _profiler._get_func_rec(self,func,force)
   -- Find the function ref for the 'func' (if force and not present, create one)
   local ret = self.rawstats[func];
   if( ret == nil and force ~= 1 ) then
      return nil
   end
   if( ret == nil ) then
      -- Build a new function statistics table
      ret = {}
      ret.func = func;
      ret.count = 0;
      ret.time = 0;
      ret.anon_child_time = 0;
      ret.name_child_time = 0;
      ret.children = {}      
      ret.children_time = {}
      self.rawstats[func] = ret;
   end
   return ret
end


--
-- This writes a profile report to the output file object.  If
-- sort_by_total_time is nil or false the output is sorted by
-- the function time minus the time in it's children.
--
function _profiler.report( self, outfile, sort_by_total_time )

   outfile:write( [[Lua Profile output created by profiler.lua. Copyright Pepperfish 2002+

]] )

   local total_time = 0;
   local ordering = {}
   for func,record in self.rawstats do
      table.insert(ordering, func);
   end

	if ( sort_by_total_time ) then

	   table.sort( ordering, 
			function(a,b)
				return self.rawstats[a] > self.rawstats[b]
			end
		)
	
	else
		
		table.sort( ordering, 
			function(a,b)
				local arec = self.rawstats[a] 
				local brec = self.rawstats[b]
				local atime = arec.time - ( arec.anon_child_time + arec.name_child_time )
				local btime = brec.time - ( brec.anon_child_time + brec.name_child_time )
				return atime > btime
			end
		)

	end

   for i=1,table.getn(ordering) do
      local func = ordering[i]
      local record = self.rawstats[func]
      local thisfuncname = " " .. self:_pretty_name(func) .. " ";
      if( string.len( thisfuncname ) < 42 ) then
	 thisfuncname = string.rep( "-", (42 - string.len(thisfuncname))/2 ) .. thisfuncname;
	 thisfuncname = thisfuncname .. string.rep( "-", 42 - string.len(thisfuncname) );
      end

      total_time = total_time + ( record.time - ( record.anon_child_time + record.name_child_time ) )
      outfile:write( string.rep( "-", 19 ) .. thisfuncname .. string.rep( "-", 19 ) .. "\n" )
      outfile:write( "                 Call count: " .. string.format( "%4d", record.count ) .. "\n" )
      outfile:write( "                 Total time: " .. string.format( "%4.3f", record.time ) .. "s\n" )
      outfile:write( "     Time spent in children: " .. string.format( "%4.3f", record.anon_child_time + record.name_child_time ) .. "s\n" )
      outfile:write( "         Time spent in self: " .. string.format( "%4.3f", record.time - ( record.anon_child_time + record.name_child_time ) ) .. "s\n" )
      outfile:write( "        Time spent per call: " .. string.format( "%4.5f", record.time/record.count ) .. "s/call\n" )
      outfile:write( "Time spent in self per call: " .. string.format( "%4.5f", (record.time - ( record.anon_child_time + record.name_child_time ))/record.count ) .. "s/call\n" )

      -- Report on each child in the form
      -- Child  <funcname> called n times and took a.bs
      local added_blank = 0
      for k,v in record.children do
	 if( self.prevented_functions[k] == nil or self.prevented_functions[k] == 0 ) then
	    if( added_blank == 0 ) then
	       outfile:write( "\n" ); -- extra separation line
	       added_blank = 1;
	    end
	    outfile:write( "Child " .. self:_pretty_name(k) .. string.rep( " ", 41-string.len(self:_pretty_name(k)) ) .. " called " .. string.format("%6d", v) )
	    outfile:write( " times. Took " .. string.format("%4.2f", record.children_time[k] ) .. "s\n" )
	 end
      end

      outfile:write( "\n" ); -- extra separation line
      outfile:flush()
   end
   outfile:write( "\n\n" )
   outfile:write( "Total time spent in profiled functions: " .. string.format("%5.3g",total_time) .. "s\n" )
   outfile:write( [[

END
]] )
   outfile:flush()
end


--
-- This writes the profile to the output file object as 
-- loadable Lua source.
--
function _profiler.lua_report(self,outfile)
   -- Purpose: Write out the entire raw state in a cross-referenceable form.
   local ordering = {}
   local functonum = {}
   for func,record in self.rawstats do
      table.insert(ordering, func);
      functonum[func] = table.getn(ordering);
   end

   outfile:write( "-- Profile generated by profiler.lua Copyright Pepperfish 2002+\n\n" );
   outfile:write( "-- Function names\nfuncnames = {}\n" );
   for i=1,table.getn(ordering) do
      local thisfunc = ordering[i];
      outfile:write( "funcnames[" .. i .. "] = " .. string.format("%q", self:_pretty_name(thisfunc)) .. "\n" );
   end
   outfile:write( "\n" );
   outfile:write( "-- Function times\nfunctimes = {}\n" );
   for i=1,table.getn(ordering) do
      local thisfunc = ordering[i];
      local record = self.rawstats[thisfunc];
      outfile:write( "functimes[" .. i .. "] = { " );
      outfile:write( "tot=" .. record.time .. ", " );
      outfile:write( "achild=" .. record.anon_child_time .. ", " );
      outfile:write( "nchild=" .. record.name_child_time .. ", " );
      outfile:write( "count=" .. record.count .. " }\n" );
   end
   outfile:write( "\n" );
   outfile:write( "-- Child links\nchildren = {}\n" );
   for i=1,table.getn(ordering) do
      local thisfunc = ordering[i];
      local record = self.rawstats[thisfunc];
      outfile:write( "children[" .. i .. "] = { " );
      for k,v in record.children do
	 if( functonum[k] ) then -- non-recorded functions will be ignored now
	    outfile:write( functonum[k] .. ", " );
	 end
      end
      outfile:write( "}\n" );
   end
   outfile:write( "\n" );
   outfile:write( "-- Child call counts\nchildcounts = {}\n" );
   for i=1,table.getn(ordering) do
      local thisfunc = ordering[i];
      local record = self.rawstats[thisfunc];
      outfile:write( "children[" .. i .. "] = { " );
      for k,v in record.children do
	 if( functonum[k] ) then -- non-recorded functions will be ignored now
	    outfile:write( v .. ", " );
	 end
      end
      outfile:write( "}\n" );
   end
   outfile:write( "\n" );
   outfile:write( "-- Child call time\nchildtimes = {}\n" );
   for i=1,table.getn(ordering) do
      local thisfunc = ordering[i];
      local record = self.rawstats[thisfunc];
      outfile:write( "children[" .. i .. "] = { " );
      for k,v in record.children do
	 if( functonum[k] ) then -- non-recorded functions will be ignored now
	    outfile:write( record.children_time[k] .. ", " );
	 end
      end
      outfile:write( "}\n" );
   end
   outfile:write( "\n\n-- That is all.\n\n" );
   outfile:flush();
end

-- Internal function to calculate a pretty name for the profile output
function _profiler._pretty_name(self,func)

   -- Only the data collected during the actual
   -- run seems to be correct.... why?
   local info = self.rawstats[ func ].func_info
   -- local info = debug.getinfo( func )

   local name = "";
   if( info.what == "Lua" ) then
      name = "L:"
   end
   if( info.what == "C" ) then
      name = "C:"
   end
   if( info.what == "main" ) then
      name = " :"
   end
   
   if( info.name == nil ) then
      name = name .. "<"..tostring(func) .. ">"
   else
      name = name .. info.name
   end

   if( info.source ) then
      name = name .. "@" .. info.source
   else
      if( info.what == "C" ) then
	 name = name .. "@?"
      else
	 name = name .. "@<string>"
      end
   end
   name = name .. ":"
   if( info.what == "C" ) then
      name = name .. "?"
   else
      name = name .. info.linedefined
   end

   return name
end


--
-- This allows you to specify functions which you do
-- not want profiled.  Setting level to 1 keeps the
-- function from being profiled.  Setting level to 2
-- keeps both the function and its children from
-- being profiled.
--
function _profiler.prevent(self, func, level)
   self.prevented_functions[func] = (level or 1)
end


_profiler.prevented_functions = {
   [ _profiler.start             ] = 2,
   [ _profiler.stop              ] = 2,
   [ _profiler._internal_profile ] = 2,
   [ _profiler_hook_wrapper      ] = 2,
   [ _profiler.prevent           ] = 2,
   [ _profiler._get_func_rec     ] = 2,
   [ _profiler.report            ] = 2,
   [ _profiler.lua_report        ] = 2,
   [ _profiler._pretty_name      ] = 2
}
