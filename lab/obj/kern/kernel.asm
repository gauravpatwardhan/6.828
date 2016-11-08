
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 33 00 00 00       	call   f0100071 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/kclock.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 08             	sub    $0x8,%esp
f0100046:	8b 45 08             	mov    0x8(%ebp),%eax
//	cprintf("entering test_backtrace %d\n", x);
	if (x > 0)
f0100049:	85 c0                	test   %eax,%eax
f010004b:	7e 11                	jle    f010005e <test_backtrace+0x1e>
		test_backtrace(x-1);
f010004d:	83 ec 0c             	sub    $0xc,%esp
f0100050:	83 e8 01             	sub    $0x1,%eax
f0100053:	50                   	push   %eax
f0100054:	e8 e7 ff ff ff       	call   f0100040 <test_backtrace>
f0100059:	83 c4 10             	add    $0x10,%esp
f010005c:	eb 11                	jmp    f010006f <test_backtrace+0x2f>
	else
		mon_backtrace(0, 0, 0);
f010005e:	83 ec 04             	sub    $0x4,%esp
f0100061:	6a 00                	push   $0x0
f0100063:	6a 00                	push   $0x0
f0100065:	6a 00                	push   $0x0
f0100067:	e8 ed 06 00 00       	call   f0100759 <mon_backtrace>
f010006c:	83 c4 10             	add    $0x10,%esp
//	cprintf("leaving test_backtrace %d\n", x);
}
f010006f:	c9                   	leave  
f0100070:	c3                   	ret    

f0100071 <i386_init>:

void
i386_init(void)
{
f0100071:	55                   	push   %ebp
f0100072:	89 e5                	mov    %esp,%ebp
f0100074:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100077:	b8 50 39 11 f0       	mov    $0xf0113950,%eax
f010007c:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100081:	50                   	push   %eax
f0100082:	6a 00                	push   $0x0
f0100084:	68 00 33 11 f0       	push   $0xf0113300
f0100089:	e8 4e 15 00 00       	call   f01015dc <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010008e:	e8 94 04 00 00       	call   f0100527 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100093:	83 c4 08             	add    $0x8,%esp
f0100096:	68 ac 1a 00 00       	push   $0x1aac
f010009b:	68 80 1a 10 f0       	push   $0xf0101a80
f01000a0:	e8 7e 0a 00 00       	call   f0100b23 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000a5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ac:	e8 8f ff ff ff       	call   f0100040 <test_backtrace>

	// Lab 2 memory initialization functions
	mem_init();
f01000b1:	e8 a5 08 00 00       	call   f010095b <mem_init>
f01000b6:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000b9:	83 ec 0c             	sub    $0xc,%esp
f01000bc:	6a 00                	push   $0x0
f01000be:	e8 64 07 00 00       	call   f0100827 <monitor>
f01000c3:	83 c4 10             	add    $0x10,%esp
f01000c6:	eb f1                	jmp    f01000b9 <i386_init+0x48>

f01000c8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000c8:	55                   	push   %ebp
f01000c9:	89 e5                	mov    %esp,%ebp
f01000cb:	56                   	push   %esi
f01000cc:	53                   	push   %ebx
f01000cd:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000d0:	83 3d 40 39 11 f0 00 	cmpl   $0x0,0xf0113940
f01000d7:	75 37                	jne    f0100110 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000d9:	89 35 40 39 11 f0    	mov    %esi,0xf0113940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000df:	fa                   	cli    
f01000e0:	fc                   	cld    

	va_start(ap, fmt);
f01000e1:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e4:	83 ec 04             	sub    $0x4,%esp
f01000e7:	ff 75 0c             	pushl  0xc(%ebp)
f01000ea:	ff 75 08             	pushl  0x8(%ebp)
f01000ed:	68 9b 1a 10 f0       	push   $0xf0101a9b
f01000f2:	e8 2c 0a 00 00       	call   f0100b23 <cprintf>
	vcprintf(fmt, ap);
f01000f7:	83 c4 08             	add    $0x8,%esp
f01000fa:	53                   	push   %ebx
f01000fb:	56                   	push   %esi
f01000fc:	e8 fc 09 00 00       	call   f0100afd <vcprintf>
	cprintf("\n");
f0100101:	c7 04 24 d7 1a 10 f0 	movl   $0xf0101ad7,(%esp)
f0100108:	e8 16 0a 00 00       	call   f0100b23 <cprintf>
	va_end(ap);
f010010d:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100110:	83 ec 0c             	sub    $0xc,%esp
f0100113:	6a 00                	push   $0x0
f0100115:	e8 0d 07 00 00       	call   f0100827 <monitor>
f010011a:	83 c4 10             	add    $0x10,%esp
f010011d:	eb f1                	jmp    f0100110 <_panic+0x48>

f010011f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011f:	55                   	push   %ebp
f0100120:	89 e5                	mov    %esp,%ebp
f0100122:	53                   	push   %ebx
f0100123:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100126:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100129:	ff 75 0c             	pushl  0xc(%ebp)
f010012c:	ff 75 08             	pushl  0x8(%ebp)
f010012f:	68 b3 1a 10 f0       	push   $0xf0101ab3
f0100134:	e8 ea 09 00 00       	call   f0100b23 <cprintf>
	vcprintf(fmt, ap);
f0100139:	83 c4 08             	add    $0x8,%esp
f010013c:	53                   	push   %ebx
f010013d:	ff 75 10             	pushl  0x10(%ebp)
f0100140:	e8 b8 09 00 00       	call   f0100afd <vcprintf>
	cprintf("\n");
f0100145:	c7 04 24 d7 1a 10 f0 	movl   $0xf0101ad7,(%esp)
f010014c:	e8 d2 09 00 00       	call   f0100b23 <cprintf>
	va_end(ap);
}
f0100151:	83 c4 10             	add    $0x10,%esp
f0100154:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100157:	c9                   	leave  
f0100158:	c3                   	ret    

f0100159 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100159:	55                   	push   %ebp
f010015a:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010015c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100161:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100162:	a8 01                	test   $0x1,%al
f0100164:	74 0b                	je     f0100171 <serial_proc_data+0x18>
f0100166:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010016b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010016c:	0f b6 c0             	movzbl %al,%eax
f010016f:	eb 05                	jmp    f0100176 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100176:	5d                   	pop    %ebp
f0100177:	c3                   	ret    

f0100178 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100178:	55                   	push   %ebp
f0100179:	89 e5                	mov    %esp,%ebp
f010017b:	53                   	push   %ebx
f010017c:	83 ec 04             	sub    $0x4,%esp
f010017f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100181:	eb 2b                	jmp    f01001ae <cons_intr+0x36>
		if (c == 0)
f0100183:	85 c0                	test   %eax,%eax
f0100185:	74 27                	je     f01001ae <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100187:	8b 0d 24 35 11 f0    	mov    0xf0113524,%ecx
f010018d:	8d 51 01             	lea    0x1(%ecx),%edx
f0100190:	89 15 24 35 11 f0    	mov    %edx,0xf0113524
f0100196:	88 81 20 33 11 f0    	mov    %al,-0xfeecce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010019c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001a2:	75 0a                	jne    f01001ae <cons_intr+0x36>
			cons.wpos = 0;
f01001a4:	c7 05 24 35 11 f0 00 	movl   $0x0,0xf0113524
f01001ab:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001ae:	ff d3                	call   *%ebx
f01001b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001b3:	75 ce                	jne    f0100183 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001b5:	83 c4 04             	add    $0x4,%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5d                   	pop    %ebp
f01001ba:	c3                   	ret    

f01001bb <kbd_proc_data>:
f01001bb:	ba 64 00 00 00       	mov    $0x64,%edx
f01001c0:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001c1:	a8 01                	test   $0x1,%al
f01001c3:	0f 84 f0 00 00 00    	je     f01002b9 <kbd_proc_data+0xfe>
f01001c9:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ce:	ec                   	in     (%dx),%al
f01001cf:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001d1:	3c e0                	cmp    $0xe0,%al
f01001d3:	75 0d                	jne    f01001e2 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001d5:	83 0d 00 33 11 f0 40 	orl    $0x40,0xf0113300
		return 0;
f01001dc:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001e1:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001e2:	55                   	push   %ebp
f01001e3:	89 e5                	mov    %esp,%ebp
f01001e5:	53                   	push   %ebx
f01001e6:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001e9:	84 c0                	test   %al,%al
f01001eb:	79 36                	jns    f0100223 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ed:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f01001f3:	89 cb                	mov    %ecx,%ebx
f01001f5:	83 e3 40             	and    $0x40,%ebx
f01001f8:	83 e0 7f             	and    $0x7f,%eax
f01001fb:	85 db                	test   %ebx,%ebx
f01001fd:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100200:	0f b6 d2             	movzbl %dl,%edx
f0100203:	0f b6 82 20 1c 10 f0 	movzbl -0xfefe3e0(%edx),%eax
f010020a:	83 c8 40             	or     $0x40,%eax
f010020d:	0f b6 c0             	movzbl %al,%eax
f0100210:	f7 d0                	not    %eax
f0100212:	21 c8                	and    %ecx,%eax
f0100214:	a3 00 33 11 f0       	mov    %eax,0xf0113300
		return 0;
f0100219:	b8 00 00 00 00       	mov    $0x0,%eax
f010021e:	e9 9e 00 00 00       	jmp    f01002c1 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100223:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f0100229:	f6 c1 40             	test   $0x40,%cl
f010022c:	74 0e                	je     f010023c <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010022e:	83 c8 80             	or     $0xffffff80,%eax
f0100231:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100233:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100236:	89 0d 00 33 11 f0    	mov    %ecx,0xf0113300
	}

	shift |= shiftcode[data];
f010023c:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010023f:	0f b6 82 20 1c 10 f0 	movzbl -0xfefe3e0(%edx),%eax
f0100246:	0b 05 00 33 11 f0    	or     0xf0113300,%eax
f010024c:	0f b6 8a 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%ecx
f0100253:	31 c8                	xor    %ecx,%eax
f0100255:	a3 00 33 11 f0       	mov    %eax,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f010025a:	89 c1                	mov    %eax,%ecx
f010025c:	83 e1 03             	and    $0x3,%ecx
f010025f:	8b 0c 8d 00 1b 10 f0 	mov    -0xfefe500(,%ecx,4),%ecx
f0100266:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010026a:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010026d:	a8 08                	test   $0x8,%al
f010026f:	74 1b                	je     f010028c <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100271:	89 da                	mov    %ebx,%edx
f0100273:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100276:	83 f9 19             	cmp    $0x19,%ecx
f0100279:	77 05                	ja     f0100280 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010027b:	83 eb 20             	sub    $0x20,%ebx
f010027e:	eb 0c                	jmp    f010028c <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100280:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100283:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100286:	83 fa 19             	cmp    $0x19,%edx
f0100289:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010028c:	f7 d0                	not    %eax
f010028e:	a8 06                	test   $0x6,%al
f0100290:	75 2d                	jne    f01002bf <kbd_proc_data+0x104>
f0100292:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100298:	75 25                	jne    f01002bf <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010029a:	83 ec 0c             	sub    $0xc,%esp
f010029d:	68 cd 1a 10 f0       	push   $0xf0101acd
f01002a2:	e8 7c 08 00 00       	call   f0100b23 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a7:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ac:	b8 03 00 00 00       	mov    $0x3,%eax
f01002b1:	ee                   	out    %al,(%dx)
f01002b2:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b5:	89 d8                	mov    %ebx,%eax
f01002b7:	eb 08                	jmp    f01002c1 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002be:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002bf:	89 d8                	mov    %ebx,%eax
}
f01002c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002c4:	c9                   	leave  
f01002c5:	c3                   	ret    

f01002c6 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002c6:	55                   	push   %ebp
f01002c7:	89 e5                	mov    %esp,%ebp
f01002c9:	57                   	push   %edi
f01002ca:	56                   	push   %esi
f01002cb:	53                   	push   %ebx
f01002cc:	83 ec 1c             	sub    $0x1c,%esp
f01002cf:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002d1:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d6:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002db:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e0:	eb 09                	jmp    f01002eb <cons_putc+0x25>
f01002e2:	89 ca                	mov    %ecx,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	ec                   	in     (%dx),%al
f01002e6:	ec                   	in     (%dx),%al
f01002e7:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002e8:	83 c3 01             	add    $0x1,%ebx
f01002eb:	89 f2                	mov    %esi,%edx
f01002ed:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002ee:	a8 20                	test   $0x20,%al
f01002f0:	75 08                	jne    f01002fa <cons_putc+0x34>
f01002f2:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f8:	7e e8                	jle    f01002e2 <cons_putc+0x1c>
f01002fa:	89 f8                	mov    %edi,%eax
f01002fc:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100304:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100305:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030a:	be 79 03 00 00       	mov    $0x379,%esi
f010030f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100314:	eb 09                	jmp    f010031f <cons_putc+0x59>
f0100316:	89 ca                	mov    %ecx,%edx
f0100318:	ec                   	in     (%dx),%al
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	83 c3 01             	add    $0x1,%ebx
f010031f:	89 f2                	mov    %esi,%edx
f0100321:	ec                   	in     (%dx),%al
f0100322:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100328:	7f 04                	jg     f010032e <cons_putc+0x68>
f010032a:	84 c0                	test   %al,%al
f010032c:	79 e8                	jns    f0100316 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100333:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100337:	ee                   	out    %al,(%dx)
f0100338:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010033d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100342:	ee                   	out    %al,(%dx)
f0100343:	b8 08 00 00 00       	mov    $0x8,%eax
f0100348:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100349:	89 fa                	mov    %edi,%edx
f010034b:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100351:	89 f8                	mov    %edi,%eax
f0100353:	80 cc 07             	or     $0x7,%ah
f0100356:	85 d2                	test   %edx,%edx
f0100358:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010035b:	89 f8                	mov    %edi,%eax
f010035d:	0f b6 c0             	movzbl %al,%eax
f0100360:	83 f8 09             	cmp    $0x9,%eax
f0100363:	74 74                	je     f01003d9 <cons_putc+0x113>
f0100365:	83 f8 09             	cmp    $0x9,%eax
f0100368:	7f 0a                	jg     f0100374 <cons_putc+0xae>
f010036a:	83 f8 08             	cmp    $0x8,%eax
f010036d:	74 14                	je     f0100383 <cons_putc+0xbd>
f010036f:	e9 99 00 00 00       	jmp    f010040d <cons_putc+0x147>
f0100374:	83 f8 0a             	cmp    $0xa,%eax
f0100377:	74 3a                	je     f01003b3 <cons_putc+0xed>
f0100379:	83 f8 0d             	cmp    $0xd,%eax
f010037c:	74 3d                	je     f01003bb <cons_putc+0xf5>
f010037e:	e9 8a 00 00 00       	jmp    f010040d <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100383:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f010038a:	66 85 c0             	test   %ax,%ax
f010038d:	0f 84 e6 00 00 00    	je     f0100479 <cons_putc+0x1b3>
			crt_pos--;
f0100393:	83 e8 01             	sub    $0x1,%eax
f0100396:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010039c:	0f b7 c0             	movzwl %ax,%eax
f010039f:	66 81 e7 00 ff       	and    $0xff00,%di
f01003a4:	83 cf 20             	or     $0x20,%edi
f01003a7:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f01003ad:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003b1:	eb 78                	jmp    f010042b <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003b3:	66 83 05 28 35 11 f0 	addw   $0x50,0xf0113528
f01003ba:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003bb:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f01003c2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c8:	c1 e8 16             	shr    $0x16,%eax
f01003cb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ce:	c1 e0 04             	shl    $0x4,%eax
f01003d1:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
f01003d7:	eb 52                	jmp    f010042b <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003de:	e8 e3 fe ff ff       	call   f01002c6 <cons_putc>
		cons_putc(' ');
f01003e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e8:	e8 d9 fe ff ff       	call   f01002c6 <cons_putc>
		cons_putc(' ');
f01003ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f2:	e8 cf fe ff ff       	call   f01002c6 <cons_putc>
		cons_putc(' ');
f01003f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fc:	e8 c5 fe ff ff       	call   f01002c6 <cons_putc>
		cons_putc(' ');
f0100401:	b8 20 00 00 00       	mov    $0x20,%eax
f0100406:	e8 bb fe ff ff       	call   f01002c6 <cons_putc>
f010040b:	eb 1e                	jmp    f010042b <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010040d:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f0100414:	8d 50 01             	lea    0x1(%eax),%edx
f0100417:	66 89 15 28 35 11 f0 	mov    %dx,0xf0113528
f010041e:	0f b7 c0             	movzwl %ax,%eax
f0100421:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f0100427:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010042b:	66 81 3d 28 35 11 f0 	cmpw   $0x7cf,0xf0113528
f0100432:	cf 07 
f0100434:	76 43                	jbe    f0100479 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100436:	a1 2c 35 11 f0       	mov    0xf011352c,%eax
f010043b:	83 ec 04             	sub    $0x4,%esp
f010043e:	68 00 0f 00 00       	push   $0xf00
f0100443:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100449:	52                   	push   %edx
f010044a:	50                   	push   %eax
f010044b:	e8 d9 11 00 00       	call   f0101629 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100450:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f0100456:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010045c:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100462:	83 c4 10             	add    $0x10,%esp
f0100465:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010046a:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010046d:	39 d0                	cmp    %edx,%eax
f010046f:	75 f4                	jne    f0100465 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100471:	66 83 2d 28 35 11 f0 	subw   $0x50,0xf0113528
f0100478:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100479:	8b 0d 30 35 11 f0    	mov    0xf0113530,%ecx
f010047f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100484:	89 ca                	mov    %ecx,%edx
f0100486:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100487:	0f b7 1d 28 35 11 f0 	movzwl 0xf0113528,%ebx
f010048e:	8d 71 01             	lea    0x1(%ecx),%esi
f0100491:	89 d8                	mov    %ebx,%eax
f0100493:	66 c1 e8 08          	shr    $0x8,%ax
f0100497:	89 f2                	mov    %esi,%edx
f0100499:	ee                   	out    %al,(%dx)
f010049a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010049f:	89 ca                	mov    %ecx,%edx
f01004a1:	ee                   	out    %al,(%dx)
f01004a2:	89 d8                	mov    %ebx,%eax
f01004a4:	89 f2                	mov    %esi,%edx
f01004a6:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004aa:	5b                   	pop    %ebx
f01004ab:	5e                   	pop    %esi
f01004ac:	5f                   	pop    %edi
f01004ad:	5d                   	pop    %ebp
f01004ae:	c3                   	ret    

f01004af <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004af:	80 3d 34 35 11 f0 00 	cmpb   $0x0,0xf0113534
f01004b6:	74 11                	je     f01004c9 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b8:	55                   	push   %ebp
f01004b9:	89 e5                	mov    %esp,%ebp
f01004bb:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004be:	b8 59 01 10 f0       	mov    $0xf0100159,%eax
f01004c3:	e8 b0 fc ff ff       	call   f0100178 <cons_intr>
}
f01004c8:	c9                   	leave  
f01004c9:	f3 c3                	repz ret 

f01004cb <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004cb:	55                   	push   %ebp
f01004cc:	89 e5                	mov    %esp,%ebp
f01004ce:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004d1:	b8 bb 01 10 f0       	mov    $0xf01001bb,%eax
f01004d6:	e8 9d fc ff ff       	call   f0100178 <cons_intr>
}
f01004db:	c9                   	leave  
f01004dc:	c3                   	ret    

f01004dd <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004dd:	55                   	push   %ebp
f01004de:	89 e5                	mov    %esp,%ebp
f01004e0:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004e3:	e8 c7 ff ff ff       	call   f01004af <serial_intr>
	kbd_intr();
f01004e8:	e8 de ff ff ff       	call   f01004cb <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ed:	a1 20 35 11 f0       	mov    0xf0113520,%eax
f01004f2:	3b 05 24 35 11 f0    	cmp    0xf0113524,%eax
f01004f8:	74 26                	je     f0100520 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004fa:	8d 50 01             	lea    0x1(%eax),%edx
f01004fd:	89 15 20 35 11 f0    	mov    %edx,0xf0113520
f0100503:	0f b6 88 20 33 11 f0 	movzbl -0xfeecce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010050a:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010050c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100512:	75 11                	jne    f0100525 <cons_getc+0x48>
			cons.rpos = 0;
f0100514:	c7 05 20 35 11 f0 00 	movl   $0x0,0xf0113520
f010051b:	00 00 00 
f010051e:	eb 05                	jmp    f0100525 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100520:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100525:	c9                   	leave  
f0100526:	c3                   	ret    

f0100527 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100527:	55                   	push   %ebp
f0100528:	89 e5                	mov    %esp,%ebp
f010052a:	57                   	push   %edi
f010052b:	56                   	push   %esi
f010052c:	53                   	push   %ebx
f010052d:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100530:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100537:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010053e:	5a a5 
	if (*cp != 0xA55A) {
f0100540:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100547:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010054b:	74 11                	je     f010055e <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010054d:	c7 05 30 35 11 f0 b4 	movl   $0x3b4,0xf0113530
f0100554:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100557:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010055c:	eb 16                	jmp    f0100574 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010055e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100565:	c7 05 30 35 11 f0 d4 	movl   $0x3d4,0xf0113530
f010056c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010056f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100574:	8b 3d 30 35 11 f0    	mov    0xf0113530,%edi
f010057a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010057f:	89 fa                	mov    %edi,%edx
f0100581:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100582:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100585:	89 da                	mov    %ebx,%edx
f0100587:	ec                   	in     (%dx),%al
f0100588:	0f b6 c8             	movzbl %al,%ecx
f010058b:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010058e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100593:	89 fa                	mov    %edi,%edx
f0100595:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100596:	89 da                	mov    %ebx,%edx
f0100598:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100599:	89 35 2c 35 11 f0    	mov    %esi,0xf011352c
	crt_pos = pos;
f010059f:	0f b6 c0             	movzbl %al,%eax
f01005a2:	09 c8                	or     %ecx,%eax
f01005a4:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005aa:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005af:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b4:	89 f2                	mov    %esi,%edx
f01005b6:	ee                   	out    %al,(%dx)
f01005b7:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005bc:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005c1:	ee                   	out    %al,(%dx)
f01005c2:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005c7:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005cc:	89 da                	mov    %ebx,%edx
f01005ce:	ee                   	out    %al,(%dx)
f01005cf:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d9:	ee                   	out    %al,(%dx)
f01005da:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005df:	b8 03 00 00 00       	mov    $0x3,%eax
f01005e4:	ee                   	out    %al,(%dx)
f01005e5:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ef:	ee                   	out    %al,(%dx)
f01005f0:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005f5:	b8 01 00 00 00       	mov    $0x1,%eax
f01005fa:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fb:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100600:	ec                   	in     (%dx),%al
f0100601:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100603:	3c ff                	cmp    $0xff,%al
f0100605:	0f 95 05 34 35 11 f0 	setne  0xf0113534
f010060c:	89 f2                	mov    %esi,%edx
f010060e:	ec                   	in     (%dx),%al
f010060f:	89 da                	mov    %ebx,%edx
f0100611:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100612:	80 f9 ff             	cmp    $0xff,%cl
f0100615:	75 10                	jne    f0100627 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100617:	83 ec 0c             	sub    $0xc,%esp
f010061a:	68 d9 1a 10 f0       	push   $0xf0101ad9
f010061f:	e8 ff 04 00 00       	call   f0100b23 <cprintf>
f0100624:	83 c4 10             	add    $0x10,%esp
}
f0100627:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010062a:	5b                   	pop    %ebx
f010062b:	5e                   	pop    %esi
f010062c:	5f                   	pop    %edi
f010062d:	5d                   	pop    %ebp
f010062e:	c3                   	ret    

f010062f <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010062f:	55                   	push   %ebp
f0100630:	89 e5                	mov    %esp,%ebp
f0100632:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100635:	8b 45 08             	mov    0x8(%ebp),%eax
f0100638:	e8 89 fc ff ff       	call   f01002c6 <cons_putc>
}
f010063d:	c9                   	leave  
f010063e:	c3                   	ret    

f010063f <getchar>:

int
getchar(void)
{
f010063f:	55                   	push   %ebp
f0100640:	89 e5                	mov    %esp,%ebp
f0100642:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100645:	e8 93 fe ff ff       	call   f01004dd <cons_getc>
f010064a:	85 c0                	test   %eax,%eax
f010064c:	74 f7                	je     f0100645 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010064e:	c9                   	leave  
f010064f:	c3                   	ret    

f0100650 <iscons>:

int
iscons(int fdnum)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100653:	b8 01 00 00 00       	mov    $0x1,%eax
f0100658:	5d                   	pop    %ebp
f0100659:	c3                   	ret    

f010065a <mon_help>:



int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010065a:	55                   	push   %ebp
f010065b:	89 e5                	mov    %esp,%ebp
f010065d:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100660:	68 20 1d 10 f0       	push   $0xf0101d20
f0100665:	68 3e 1d 10 f0       	push   $0xf0101d3e
f010066a:	68 43 1d 10 f0       	push   $0xf0101d43
f010066f:	e8 af 04 00 00       	call   f0100b23 <cprintf>
f0100674:	83 c4 0c             	add    $0xc,%esp
f0100677:	68 f8 1d 10 f0       	push   $0xf0101df8
f010067c:	68 4c 1d 10 f0       	push   $0xf0101d4c
f0100681:	68 43 1d 10 f0       	push   $0xf0101d43
f0100686:	e8 98 04 00 00       	call   f0100b23 <cprintf>
f010068b:	83 c4 0c             	add    $0xc,%esp
f010068e:	68 55 1d 10 f0       	push   $0xf0101d55
f0100693:	68 6c 1d 10 f0       	push   $0xf0101d6c
f0100698:	68 43 1d 10 f0       	push   $0xf0101d43
f010069d:	e8 81 04 00 00       	call   f0100b23 <cprintf>
	return 0;
}
f01006a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01006a7:	c9                   	leave  
f01006a8:	c3                   	ret    

f01006a9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006a9:	55                   	push   %ebp
f01006aa:	89 e5                	mov    %esp,%ebp
f01006ac:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006af:	68 76 1d 10 f0       	push   $0xf0101d76
f01006b4:	e8 6a 04 00 00       	call   f0100b23 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006b9:	83 c4 08             	add    $0x8,%esp
f01006bc:	68 0c 00 10 00       	push   $0x10000c
f01006c1:	68 20 1e 10 f0       	push   $0xf0101e20
f01006c6:	e8 58 04 00 00       	call   f0100b23 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006cb:	83 c4 0c             	add    $0xc,%esp
f01006ce:	68 0c 00 10 00       	push   $0x10000c
f01006d3:	68 0c 00 10 f0       	push   $0xf010000c
f01006d8:	68 48 1e 10 f0       	push   $0xf0101e48
f01006dd:	e8 41 04 00 00       	call   f0100b23 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006e2:	83 c4 0c             	add    $0xc,%esp
f01006e5:	68 61 1a 10 00       	push   $0x101a61
f01006ea:	68 61 1a 10 f0       	push   $0xf0101a61
f01006ef:	68 6c 1e 10 f0       	push   $0xf0101e6c
f01006f4:	e8 2a 04 00 00       	call   f0100b23 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006f9:	83 c4 0c             	add    $0xc,%esp
f01006fc:	68 00 33 11 00       	push   $0x113300
f0100701:	68 00 33 11 f0       	push   $0xf0113300
f0100706:	68 90 1e 10 f0       	push   $0xf0101e90
f010070b:	e8 13 04 00 00       	call   f0100b23 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100710:	83 c4 0c             	add    $0xc,%esp
f0100713:	68 50 39 11 00       	push   $0x113950
f0100718:	68 50 39 11 f0       	push   $0xf0113950
f010071d:	68 b4 1e 10 f0       	push   $0xf0101eb4
f0100722:	e8 fc 03 00 00       	call   f0100b23 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100727:	b8 4f 3d 11 f0       	mov    $0xf0113d4f,%eax
f010072c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100731:	83 c4 08             	add    $0x8,%esp
f0100734:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100739:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010073f:	85 c0                	test   %eax,%eax
f0100741:	0f 48 c2             	cmovs  %edx,%eax
f0100744:	c1 f8 0a             	sar    $0xa,%eax
f0100747:	50                   	push   %eax
f0100748:	68 d8 1e 10 f0       	push   $0xf0101ed8
f010074d:	e8 d1 03 00 00       	call   f0100b23 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100752:	b8 00 00 00 00       	mov    $0x0,%eax
f0100757:	c9                   	leave  
f0100758:	c3                   	ret    

f0100759 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100759:	55                   	push   %ebp
f010075a:	89 e5                	mov    %esp,%ebp
f010075c:	57                   	push   %edi
f010075d:	56                   	push   %esi
f010075e:	53                   	push   %ebx
f010075f:	83 ec 48             	sub    $0x48,%esp
	// Your code here.
	
	//basic stack backtrace code
	cprintf("Stack backtrace:\n");
f0100762:	68 8f 1d 10 f0       	push   $0xf0101d8f
f0100767:	e8 b7 03 00 00       	call   f0100b23 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010076c:	89 eb                	mov    %ebp,%ebx
	uintptr_t ebp_current_local = read_ebp();
	uintptr_t eip_current_local = 0;
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};
f010076e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100775:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010077c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100783:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010078a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
f0100791:	83 c4 0c             	add    $0xc,%esp
f0100794:	6a 18                	push   $0x18
f0100796:	6a 00                	push   $0x0
f0100798:	8d 45 bc             	lea    -0x44(%ebp),%eax
f010079b:	50                   	push   %eax
f010079c:	e8 3b 0e 00 00       	call   f01015dc <memset>
	while (ebp_current_local != 0){
f01007a1:	83 c4 10             	add    $0x10,%esp
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f01007a4:	8d 7d bc             	lea    -0x44(%ebp),%edi
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f01007a7:	eb 6d                	jmp    f0100816 <mon_backtrace+0xbd>
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
f01007a9:	8b 73 04             	mov    0x4(%ebx),%esi
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007ac:	b8 00 00 00 00       	mov    $0x0,%eax
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
f01007b1:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01007b5:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007b9:	83 c0 01             	add    $0x1,%eax
f01007bc:	83 f8 05             	cmp    $0x5,%eax
f01007bf:	75 f0                	jne    f01007b1 <mon_backtrace+0x58>
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
f01007c1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007c4:	ff 75 e0             	pushl  -0x20(%ebp)
f01007c7:	ff 75 dc             	pushl  -0x24(%ebp)
f01007ca:	ff 75 d8             	pushl  -0x28(%ebp)
f01007cd:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007d0:	56                   	push   %esi
f01007d1:	53                   	push   %ebx
f01007d2:	68 04 1f 10 f0       	push   $0xf0101f04
f01007d7:	e8 47 03 00 00       	call   f0100b23 <cprintf>
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f01007dc:	83 c4 18             	add    $0x18,%esp
f01007df:	57                   	push   %edi
f01007e0:	56                   	push   %esi
f01007e1:	e8 47 04 00 00       	call   f0100c2d <debuginfo_eip>
f01007e6:	83 c4 10             	add    $0x10,%esp
f01007e9:	85 c0                	test   %eax,%eax
f01007eb:	75 20                	jne    f010080d <mon_backtrace+0xb4>
				cprintf("        %s:%d: %.*s+%d\n", eipinfo.eip_file, eipinfo.eip_line, 
f01007ed:	83 ec 08             	sub    $0x8,%esp
f01007f0:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f3:	56                   	push   %esi
f01007f4:	ff 75 c4             	pushl  -0x3c(%ebp)
f01007f7:	ff 75 c8             	pushl  -0x38(%ebp)
f01007fa:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fd:	ff 75 bc             	pushl  -0x44(%ebp)
f0100800:	68 a1 1d 10 f0       	push   $0xf0101da1
f0100805:	e8 19 03 00 00       	call   f0100b23 <cprintf>
f010080a:	83 c4 20             	add    $0x20,%esp
						eipinfo.eip_fn_namelen, eipinfo.eip_fn_name, eip_current_local-eipinfo.eip_fn_addr);

		}
		// point the ebp to the next ebp using the current ebp value pushed on stack	
		ebp_current_local = *(uintptr_t *)(ebp_current_local);
f010080d:	8b 1b                	mov    (%ebx),%ebx
f010080f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f0100816:	85 db                	test   %ebx,%ebx
f0100818:	75 8f                	jne    f01007a9 <mon_backtrace+0x50>
		for ( i = 0; i < MAX_ARGS_PASSED; i++){
			args_arr[0] = 0;
		}
	}
	return 0;
}
f010081a:	b8 00 00 00 00       	mov    $0x0,%eax
f010081f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100822:	5b                   	pop    %ebx
f0100823:	5e                   	pop    %esi
f0100824:	5f                   	pop    %edi
f0100825:	5d                   	pop    %ebp
f0100826:	c3                   	ret    

f0100827 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100827:	55                   	push   %ebp
f0100828:	89 e5                	mov    %esp,%ebp
f010082a:	57                   	push   %edi
f010082b:	56                   	push   %esi
f010082c:	53                   	push   %ebx
f010082d:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100830:	68 38 1f 10 f0       	push   $0xf0101f38
f0100835:	e8 e9 02 00 00       	call   f0100b23 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010083a:	c7 04 24 5c 1f 10 f0 	movl   $0xf0101f5c,(%esp)
f0100841:	e8 dd 02 00 00       	call   f0100b23 <cprintf>
f0100846:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100849:	83 ec 0c             	sub    $0xc,%esp
f010084c:	68 b9 1d 10 f0       	push   $0xf0101db9
f0100851:	e8 2f 0b 00 00       	call   f0101385 <readline>
f0100856:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100858:	83 c4 10             	add    $0x10,%esp
f010085b:	85 c0                	test   %eax,%eax
f010085d:	74 ea                	je     f0100849 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010085f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100866:	be 00 00 00 00       	mov    $0x0,%esi
f010086b:	eb 0a                	jmp    f0100877 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010086d:	c6 03 00             	movb   $0x0,(%ebx)
f0100870:	89 f7                	mov    %esi,%edi
f0100872:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100875:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100877:	0f b6 03             	movzbl (%ebx),%eax
f010087a:	84 c0                	test   %al,%al
f010087c:	74 63                	je     f01008e1 <monitor+0xba>
f010087e:	83 ec 08             	sub    $0x8,%esp
f0100881:	0f be c0             	movsbl %al,%eax
f0100884:	50                   	push   %eax
f0100885:	68 bd 1d 10 f0       	push   $0xf0101dbd
f010088a:	e8 10 0d 00 00       	call   f010159f <strchr>
f010088f:	83 c4 10             	add    $0x10,%esp
f0100892:	85 c0                	test   %eax,%eax
f0100894:	75 d7                	jne    f010086d <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100896:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100899:	74 46                	je     f01008e1 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010089b:	83 fe 0f             	cmp    $0xf,%esi
f010089e:	75 14                	jne    f01008b4 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008a0:	83 ec 08             	sub    $0x8,%esp
f01008a3:	6a 10                	push   $0x10
f01008a5:	68 c2 1d 10 f0       	push   $0xf0101dc2
f01008aa:	e8 74 02 00 00       	call   f0100b23 <cprintf>
f01008af:	83 c4 10             	add    $0x10,%esp
f01008b2:	eb 95                	jmp    f0100849 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008b4:	8d 7e 01             	lea    0x1(%esi),%edi
f01008b7:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008bb:	eb 03                	jmp    f01008c0 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008bd:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008c0:	0f b6 03             	movzbl (%ebx),%eax
f01008c3:	84 c0                	test   %al,%al
f01008c5:	74 ae                	je     f0100875 <monitor+0x4e>
f01008c7:	83 ec 08             	sub    $0x8,%esp
f01008ca:	0f be c0             	movsbl %al,%eax
f01008cd:	50                   	push   %eax
f01008ce:	68 bd 1d 10 f0       	push   $0xf0101dbd
f01008d3:	e8 c7 0c 00 00       	call   f010159f <strchr>
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	85 c0                	test   %eax,%eax
f01008dd:	74 de                	je     f01008bd <monitor+0x96>
f01008df:	eb 94                	jmp    f0100875 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008e1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008e8:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008e9:	85 f6                	test   %esi,%esi
f01008eb:	0f 84 58 ff ff ff    	je     f0100849 <monitor+0x22>
f01008f1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008f6:	83 ec 08             	sub    $0x8,%esp
f01008f9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008fc:	ff 34 85 a0 1f 10 f0 	pushl  -0xfefe060(,%eax,4)
f0100903:	ff 75 a8             	pushl  -0x58(%ebp)
f0100906:	e8 36 0c 00 00       	call   f0101541 <strcmp>
f010090b:	83 c4 10             	add    $0x10,%esp
f010090e:	85 c0                	test   %eax,%eax
f0100910:	75 21                	jne    f0100933 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f0100912:	83 ec 04             	sub    $0x4,%esp
f0100915:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100918:	ff 75 08             	pushl  0x8(%ebp)
f010091b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010091e:	52                   	push   %edx
f010091f:	56                   	push   %esi
f0100920:	ff 14 85 a8 1f 10 f0 	call   *-0xfefe058(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100927:	83 c4 10             	add    $0x10,%esp
f010092a:	85 c0                	test   %eax,%eax
f010092c:	78 25                	js     f0100953 <monitor+0x12c>
f010092e:	e9 16 ff ff ff       	jmp    f0100849 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100933:	83 c3 01             	add    $0x1,%ebx
f0100936:	83 fb 03             	cmp    $0x3,%ebx
f0100939:	75 bb                	jne    f01008f6 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010093b:	83 ec 08             	sub    $0x8,%esp
f010093e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100941:	68 df 1d 10 f0       	push   $0xf0101ddf
f0100946:	e8 d8 01 00 00       	call   f0100b23 <cprintf>
f010094b:	83 c4 10             	add    $0x10,%esp
f010094e:	e9 f6 fe ff ff       	jmp    f0100849 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100953:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100956:	5b                   	pop    %ebx
f0100957:	5e                   	pop    %esi
f0100958:	5f                   	pop    %edi
f0100959:	5d                   	pop    %ebp
f010095a:	c3                   	ret    

f010095b <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010095b:	55                   	push   %ebp
f010095c:	89 e5                	mov    %esp,%ebp
f010095e:	53                   	push   %ebx
f010095f:	83 ec 10             	sub    $0x10,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100962:	6a 15                	push   $0x15
f0100964:	e8 53 01 00 00       	call   f0100abc <mc146818_read>
f0100969:	89 c3                	mov    %eax,%ebx
f010096b:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0100972:	e8 45 01 00 00       	call   f0100abc <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100977:	c1 e0 08             	shl    $0x8,%eax
f010097a:	09 d8                	or     %ebx,%eax
f010097c:	c1 e0 0a             	shl    $0xa,%eax
f010097f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100985:	85 c0                	test   %eax,%eax
f0100987:	0f 48 c2             	cmovs  %edx,%eax
f010098a:	c1 f8 0c             	sar    $0xc,%eax
f010098d:	a3 3c 35 11 f0       	mov    %eax,0xf011353c
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100992:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0100999:	e8 1e 01 00 00       	call   f0100abc <mc146818_read>
f010099e:	89 c3                	mov    %eax,%ebx
f01009a0:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01009a7:	e8 10 01 00 00       	call   f0100abc <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01009ac:	c1 e0 08             	shl    $0x8,%eax
f01009af:	09 d8                	or     %ebx,%eax
f01009b1:	c1 e0 0a             	shl    $0xa,%eax
f01009b4:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01009ba:	83 c4 10             	add    $0x10,%esp
f01009bd:	85 c0                	test   %eax,%eax
f01009bf:	0f 48 c2             	cmovs  %edx,%eax
f01009c2:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01009c5:	85 c0                	test   %eax,%eax
f01009c7:	74 0e                	je     f01009d7 <mem_init+0x7c>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01009c9:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01009cf:	89 15 44 39 11 f0    	mov    %edx,0xf0113944
f01009d5:	eb 0c                	jmp    f01009e3 <mem_init+0x88>
	else
		npages = npages_basemem;
f01009d7:	8b 15 3c 35 11 f0    	mov    0xf011353c,%edx
f01009dd:	89 15 44 39 11 f0    	mov    %edx,0xf0113944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01009e3:	c1 e0 0c             	shl    $0xc,%eax
f01009e6:	c1 e8 0a             	shr    $0xa,%eax
f01009e9:	50                   	push   %eax
f01009ea:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f01009ef:	c1 e0 0c             	shl    $0xc,%eax
f01009f2:	c1 e8 0a             	shr    $0xa,%eax
f01009f5:	50                   	push   %eax
f01009f6:	a1 44 39 11 f0       	mov    0xf0113944,%eax
f01009fb:	c1 e0 0c             	shl    $0xc,%eax
f01009fe:	c1 e8 0a             	shr    $0xa,%eax
f0100a01:	50                   	push   %eax
f0100a02:	68 c4 1f 10 f0       	push   $0xf0101fc4
f0100a07:	e8 17 01 00 00       	call   f0100b23 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f0100a0c:	83 c4 0c             	add    $0xc,%esp
f0100a0f:	68 00 20 10 f0       	push   $0xf0102000
f0100a14:	6a 7c                	push   $0x7c
f0100a16:	68 2c 20 10 f0       	push   $0xf010202c
f0100a1b:	e8 a8 f6 ff ff       	call   f01000c8 <_panic>

f0100a20 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100a20:	55                   	push   %ebp
f0100a21:	89 e5                	mov    %esp,%ebp
f0100a23:	53                   	push   %ebx
f0100a24:	8b 1d 38 35 11 f0    	mov    0xf0113538,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a34:	eb 27                	jmp    f0100a5d <page_init+0x3d>
f0100a36:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100a3d:	89 d1                	mov    %edx,%ecx
f0100a3f:	03 0d 4c 39 11 f0    	add    0xf011394c,%ecx
f0100a45:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100a4b:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a4d:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100a50:	89 d3                	mov    %edx,%ebx
f0100a52:	03 1d 4c 39 11 f0    	add    0xf011394c,%ebx
f0100a58:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a5d:	3b 05 44 39 11 f0    	cmp    0xf0113944,%eax
f0100a63:	72 d1                	jb     f0100a36 <page_init+0x16>
f0100a65:	84 d2                	test   %dl,%dl
f0100a67:	74 06                	je     f0100a6f <page_init+0x4f>
f0100a69:	89 1d 38 35 11 f0    	mov    %ebx,0xf0113538
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100a6f:	5b                   	pop    %ebx
f0100a70:	5d                   	pop    %ebp
f0100a71:	c3                   	ret    

f0100a72 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100a72:	55                   	push   %ebp
f0100a73:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100a75:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a7a:	5d                   	pop    %ebp
f0100a7b:	c3                   	ret    

f0100a7c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100a7c:	55                   	push   %ebp
f0100a7d:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100a7f:	5d                   	pop    %ebp
f0100a80:	c3                   	ret    

f0100a81 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100a81:	55                   	push   %ebp
f0100a82:	89 e5                	mov    %esp,%ebp
f0100a84:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100a87:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100a8c:	5d                   	pop    %ebp
f0100a8d:	c3                   	ret    

f0100a8e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100a8e:	55                   	push   %ebp
f0100a8f:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100a91:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a96:	5d                   	pop    %ebp
f0100a97:	c3                   	ret    

f0100a98 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100a98:	55                   	push   %ebp
f0100a99:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100a9b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aa0:	5d                   	pop    %ebp
f0100aa1:	c3                   	ret    

f0100aa2 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100aa2:	55                   	push   %ebp
f0100aa3:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100aa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aaa:	5d                   	pop    %ebp
f0100aab:	c3                   	ret    

f0100aac <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100aac:	55                   	push   %ebp
f0100aad:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100aaf:	5d                   	pop    %ebp
f0100ab0:	c3                   	ret    

f0100ab1 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100ab1:	55                   	push   %ebp
f0100ab2:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ab7:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100aba:	5d                   	pop    %ebp
f0100abb:	c3                   	ret    

f0100abc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100abf:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ac4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ac7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100ac8:	ba 71 00 00 00       	mov    $0x71,%edx
f0100acd:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100ace:	0f b6 c0             	movzbl %al,%eax
}
f0100ad1:	5d                   	pop    %ebp
f0100ad2:	c3                   	ret    

f0100ad3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100ad3:	55                   	push   %ebp
f0100ad4:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ad6:	ba 70 00 00 00       	mov    $0x70,%edx
f0100adb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ade:	ee                   	out    %al,(%dx)
f0100adf:	ba 71 00 00 00       	mov    $0x71,%edx
f0100ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ae7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100ae8:	5d                   	pop    %ebp
f0100ae9:	c3                   	ret    

f0100aea <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100aea:	55                   	push   %ebp
f0100aeb:	89 e5                	mov    %esp,%ebp
f0100aed:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100af0:	ff 75 08             	pushl  0x8(%ebp)
f0100af3:	e8 37 fb ff ff       	call   f010062f <cputchar>
	*cnt++;
}
f0100af8:	83 c4 10             	add    $0x10,%esp
f0100afb:	c9                   	leave  
f0100afc:	c3                   	ret    

f0100afd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100afd:	55                   	push   %ebp
f0100afe:	89 e5                	mov    %esp,%ebp
f0100b00:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100b03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b0a:	ff 75 0c             	pushl  0xc(%ebp)
f0100b0d:	ff 75 08             	pushl  0x8(%ebp)
f0100b10:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b13:	50                   	push   %eax
f0100b14:	68 ea 0a 10 f0       	push   $0xf0100aea
f0100b19:	e8 52 04 00 00       	call   f0100f70 <vprintfmt>
	return cnt;
}
f0100b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b21:	c9                   	leave  
f0100b22:	c3                   	ret    

f0100b23 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b23:	55                   	push   %ebp
f0100b24:	89 e5                	mov    %esp,%ebp
f0100b26:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b29:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b2c:	50                   	push   %eax
f0100b2d:	ff 75 08             	pushl  0x8(%ebp)
f0100b30:	e8 c8 ff ff ff       	call   f0100afd <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b35:	c9                   	leave  
f0100b36:	c3                   	ret    

f0100b37 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b37:	55                   	push   %ebp
f0100b38:	89 e5                	mov    %esp,%ebp
f0100b3a:	57                   	push   %edi
f0100b3b:	56                   	push   %esi
f0100b3c:	53                   	push   %ebx
f0100b3d:	83 ec 14             	sub    $0x14,%esp
f0100b40:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b46:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b49:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b4c:	8b 1a                	mov    (%edx),%ebx
f0100b4e:	8b 01                	mov    (%ecx),%eax
f0100b50:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b53:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b5a:	eb 7f                	jmp    f0100bdb <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b5f:	01 d8                	add    %ebx,%eax
f0100b61:	89 c6                	mov    %eax,%esi
f0100b63:	c1 ee 1f             	shr    $0x1f,%esi
f0100b66:	01 c6                	add    %eax,%esi
f0100b68:	d1 fe                	sar    %esi
f0100b6a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100b6d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b70:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100b73:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b75:	eb 03                	jmp    f0100b7a <stab_binsearch+0x43>
			m--;
f0100b77:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b7a:	39 c3                	cmp    %eax,%ebx
f0100b7c:	7f 0d                	jg     f0100b8b <stab_binsearch+0x54>
f0100b7e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100b82:	83 ea 0c             	sub    $0xc,%edx
f0100b85:	39 f9                	cmp    %edi,%ecx
f0100b87:	75 ee                	jne    f0100b77 <stab_binsearch+0x40>
f0100b89:	eb 05                	jmp    f0100b90 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100b8b:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100b8e:	eb 4b                	jmp    f0100bdb <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b90:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b93:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b96:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b9a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100b9d:	76 11                	jbe    f0100bb0 <stab_binsearch+0x79>
			*region_left = m;
f0100b9f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ba2:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100ba4:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ba7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bae:	eb 2b                	jmp    f0100bdb <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100bb0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100bb3:	73 14                	jae    f0100bc9 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100bb5:	83 e8 01             	sub    $0x1,%eax
f0100bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bbb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100bbe:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bc0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bc7:	eb 12                	jmp    f0100bdb <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bc9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bcc:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100bce:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bd2:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bd4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100bdb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100bde:	0f 8e 78 ff ff ff    	jle    f0100b5c <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100be4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100be8:	75 0f                	jne    f0100bf9 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100bea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bed:	8b 00                	mov    (%eax),%eax
f0100bef:	83 e8 01             	sub    $0x1,%eax
f0100bf2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100bf5:	89 06                	mov    %eax,(%esi)
f0100bf7:	eb 2c                	jmp    f0100c25 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100bf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bfc:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bfe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c01:	8b 0e                	mov    (%esi),%ecx
f0100c03:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c06:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100c09:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c0c:	eb 03                	jmp    f0100c11 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100c0e:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c11:	39 c8                	cmp    %ecx,%eax
f0100c13:	7e 0b                	jle    f0100c20 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100c15:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100c19:	83 ea 0c             	sub    $0xc,%edx
f0100c1c:	39 df                	cmp    %ebx,%edi
f0100c1e:	75 ee                	jne    f0100c0e <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100c20:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c23:	89 06                	mov    %eax,(%esi)
	}
}
f0100c25:	83 c4 14             	add    $0x14,%esp
f0100c28:	5b                   	pop    %ebx
f0100c29:	5e                   	pop    %esi
f0100c2a:	5f                   	pop    %edi
f0100c2b:	5d                   	pop    %ebp
f0100c2c:	c3                   	ret    

f0100c2d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c2d:	55                   	push   %ebp
f0100c2e:	89 e5                	mov    %esp,%ebp
f0100c30:	57                   	push   %edi
f0100c31:	56                   	push   %esi
f0100c32:	53                   	push   %ebx
f0100c33:	83 ec 3c             	sub    $0x3c,%esp
f0100c36:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c3c:	c7 03 38 20 10 f0    	movl   $0xf0102038,(%ebx)
	info->eip_line = 0;
f0100c42:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100c49:	c7 43 08 38 20 10 f0 	movl   $0xf0102038,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100c50:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100c57:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100c5a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c61:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100c67:	76 11                	jbe    f0100c7a <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c69:	b8 29 80 10 f0       	mov    $0xf0108029,%eax
f0100c6e:	3d f5 63 10 f0       	cmp    $0xf01063f5,%eax
f0100c73:	77 19                	ja     f0100c8e <debuginfo_eip+0x61>
f0100c75:	e9 aa 01 00 00       	jmp    f0100e24 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100c7a:	83 ec 04             	sub    $0x4,%esp
f0100c7d:	68 42 20 10 f0       	push   $0xf0102042
f0100c82:	6a 7f                	push   $0x7f
f0100c84:	68 4f 20 10 f0       	push   $0xf010204f
f0100c89:	e8 3a f4 ff ff       	call   f01000c8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c8e:	80 3d 28 80 10 f0 00 	cmpb   $0x0,0xf0108028
f0100c95:	0f 85 90 01 00 00    	jne    f0100e2b <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c9b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ca2:	b8 f4 63 10 f0       	mov    $0xf01063f4,%eax
f0100ca7:	2d 90 22 10 f0       	sub    $0xf0102290,%eax
f0100cac:	c1 f8 02             	sar    $0x2,%eax
f0100caf:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100cb5:	83 e8 01             	sub    $0x1,%eax
f0100cb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cbb:	83 ec 08             	sub    $0x8,%esp
f0100cbe:	56                   	push   %esi
f0100cbf:	6a 64                	push   $0x64
f0100cc1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cc4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cc7:	b8 90 22 10 f0       	mov    $0xf0102290,%eax
f0100ccc:	e8 66 fe ff ff       	call   f0100b37 <stab_binsearch>
	if (lfile == 0)
f0100cd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cd4:	83 c4 10             	add    $0x10,%esp
f0100cd7:	85 c0                	test   %eax,%eax
f0100cd9:	0f 84 53 01 00 00    	je     f0100e32 <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cdf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ce5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ce8:	83 ec 08             	sub    $0x8,%esp
f0100ceb:	56                   	push   %esi
f0100cec:	6a 24                	push   $0x24
f0100cee:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cf1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cf4:	b8 90 22 10 f0       	mov    $0xf0102290,%eax
f0100cf9:	e8 39 fe ff ff       	call   f0100b37 <stab_binsearch>

	if (lfun <= rfun) {
f0100cfe:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d01:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100d04:	83 c4 10             	add    $0x10,%esp
f0100d07:	39 d0                	cmp    %edx,%eax
f0100d09:	7f 40                	jg     f0100d4b <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d0b:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100d0e:	c1 e1 02             	shl    $0x2,%ecx
f0100d11:	8d b9 90 22 10 f0    	lea    -0xfefdd70(%ecx),%edi
f0100d17:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100d1a:	8b b9 90 22 10 f0    	mov    -0xfefdd70(%ecx),%edi
f0100d20:	b9 29 80 10 f0       	mov    $0xf0108029,%ecx
f0100d25:	81 e9 f5 63 10 f0    	sub    $0xf01063f5,%ecx
f0100d2b:	39 cf                	cmp    %ecx,%edi
f0100d2d:	73 09                	jae    f0100d38 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d2f:	81 c7 f5 63 10 f0    	add    $0xf01063f5,%edi
f0100d35:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d38:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100d3b:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100d3e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100d41:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d46:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100d49:	eb 0f                	jmp    f0100d5a <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100d4b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d57:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d5a:	83 ec 08             	sub    $0x8,%esp
f0100d5d:	6a 3a                	push   $0x3a
f0100d5f:	ff 73 08             	pushl  0x8(%ebx)
f0100d62:	e8 59 08 00 00       	call   f01015c0 <strfind>
f0100d67:	2b 43 08             	sub    0x8(%ebx),%eax
f0100d6a:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d6d:	83 c4 08             	add    $0x8,%esp
f0100d70:	56                   	push   %esi
f0100d71:	6a 44                	push   $0x44
f0100d73:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d76:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d79:	b8 90 22 10 f0       	mov    $0xf0102290,%eax
f0100d7e:	e8 b4 fd ff ff       	call   f0100b37 <stab_binsearch>
	if ( lline <= rline ){
f0100d83:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100d86:	83 c4 10             	add    $0x10,%esp
f0100d89:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d8c:	0f 8f a7 00 00 00    	jg     f0100e39 <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f0100d92:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100d95:	8d 04 85 90 22 10 f0 	lea    -0xfefdd70(,%eax,4),%eax
f0100d9c:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100da0:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100da3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100da6:	eb 06                	jmp    f0100dae <debuginfo_eip+0x181>
f0100da8:	83 ea 01             	sub    $0x1,%edx
f0100dab:	83 e8 0c             	sub    $0xc,%eax
f0100dae:	39 d6                	cmp    %edx,%esi
f0100db0:	7f 34                	jg     f0100de6 <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100db2:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100db6:	80 f9 84             	cmp    $0x84,%cl
f0100db9:	74 0b                	je     f0100dc6 <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100dbb:	80 f9 64             	cmp    $0x64,%cl
f0100dbe:	75 e8                	jne    f0100da8 <debuginfo_eip+0x17b>
f0100dc0:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100dc4:	74 e2                	je     f0100da8 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100dc6:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100dc9:	8b 14 85 90 22 10 f0 	mov    -0xfefdd70(,%eax,4),%edx
f0100dd0:	b8 29 80 10 f0       	mov    $0xf0108029,%eax
f0100dd5:	2d f5 63 10 f0       	sub    $0xf01063f5,%eax
f0100dda:	39 c2                	cmp    %eax,%edx
f0100ddc:	73 08                	jae    f0100de6 <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100dde:	81 c2 f5 63 10 f0    	add    $0xf01063f5,%edx
f0100de4:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100de6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100de9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dec:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100df1:	39 f2                	cmp    %esi,%edx
f0100df3:	7d 50                	jge    f0100e45 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100df5:	83 c2 01             	add    $0x1,%edx
f0100df8:	89 d0                	mov    %edx,%eax
f0100dfa:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100dfd:	8d 14 95 90 22 10 f0 	lea    -0xfefdd70(,%edx,4),%edx
f0100e04:	eb 04                	jmp    f0100e0a <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100e06:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100e0a:	39 c6                	cmp    %eax,%esi
f0100e0c:	7e 32                	jle    f0100e40 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e0e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100e12:	83 c0 01             	add    $0x1,%eax
f0100e15:	83 c2 0c             	add    $0xc,%edx
f0100e18:	80 f9 a0             	cmp    $0xa0,%cl
f0100e1b:	74 e9                	je     f0100e06 <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e1d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e22:	eb 21                	jmp    f0100e45 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100e24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e29:	eb 1a                	jmp    f0100e45 <debuginfo_eip+0x218>
f0100e2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e30:	eb 13                	jmp    f0100e45 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e37:	eb 0c                	jmp    f0100e45 <debuginfo_eip+0x218>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if ( lline <= rline ){
		info->eip_line = stabs[lline].n_desc;
	}
	else{
		return -1;
f0100e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e3e:	eb 05                	jmp    f0100e45 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e40:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e48:	5b                   	pop    %ebx
f0100e49:	5e                   	pop    %esi
f0100e4a:	5f                   	pop    %edi
f0100e4b:	5d                   	pop    %ebp
f0100e4c:	c3                   	ret    

f0100e4d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e4d:	55                   	push   %ebp
f0100e4e:	89 e5                	mov    %esp,%ebp
f0100e50:	57                   	push   %edi
f0100e51:	56                   	push   %esi
f0100e52:	53                   	push   %ebx
f0100e53:	83 ec 1c             	sub    $0x1c,%esp
f0100e56:	89 c7                	mov    %eax,%edi
f0100e58:	89 d6                	mov    %edx,%esi
f0100e5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e5d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e60:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e63:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e66:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100e69:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e6e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100e71:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100e74:	39 d3                	cmp    %edx,%ebx
f0100e76:	72 05                	jb     f0100e7d <printnum+0x30>
f0100e78:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100e7b:	77 45                	ja     f0100ec2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e7d:	83 ec 0c             	sub    $0xc,%esp
f0100e80:	ff 75 18             	pushl  0x18(%ebp)
f0100e83:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e86:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100e89:	53                   	push   %ebx
f0100e8a:	ff 75 10             	pushl  0x10(%ebp)
f0100e8d:	83 ec 08             	sub    $0x8,%esp
f0100e90:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e93:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e96:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e99:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e9c:	e8 3f 09 00 00       	call   f01017e0 <__udivdi3>
f0100ea1:	83 c4 18             	add    $0x18,%esp
f0100ea4:	52                   	push   %edx
f0100ea5:	50                   	push   %eax
f0100ea6:	89 f2                	mov    %esi,%edx
f0100ea8:	89 f8                	mov    %edi,%eax
f0100eaa:	e8 9e ff ff ff       	call   f0100e4d <printnum>
f0100eaf:	83 c4 20             	add    $0x20,%esp
f0100eb2:	eb 18                	jmp    f0100ecc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100eb4:	83 ec 08             	sub    $0x8,%esp
f0100eb7:	56                   	push   %esi
f0100eb8:	ff 75 18             	pushl  0x18(%ebp)
f0100ebb:	ff d7                	call   *%edi
f0100ebd:	83 c4 10             	add    $0x10,%esp
f0100ec0:	eb 03                	jmp    f0100ec5 <printnum+0x78>
f0100ec2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100ec5:	83 eb 01             	sub    $0x1,%ebx
f0100ec8:	85 db                	test   %ebx,%ebx
f0100eca:	7f e8                	jg     f0100eb4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ecc:	83 ec 08             	sub    $0x8,%esp
f0100ecf:	56                   	push   %esi
f0100ed0:	83 ec 04             	sub    $0x4,%esp
f0100ed3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ed6:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ed9:	ff 75 dc             	pushl  -0x24(%ebp)
f0100edc:	ff 75 d8             	pushl  -0x28(%ebp)
f0100edf:	e8 2c 0a 00 00       	call   f0101910 <__umoddi3>
f0100ee4:	83 c4 14             	add    $0x14,%esp
f0100ee7:	0f be 80 5d 20 10 f0 	movsbl -0xfefdfa3(%eax),%eax
f0100eee:	50                   	push   %eax
f0100eef:	ff d7                	call   *%edi
}
f0100ef1:	83 c4 10             	add    $0x10,%esp
f0100ef4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ef7:	5b                   	pop    %ebx
f0100ef8:	5e                   	pop    %esi
f0100ef9:	5f                   	pop    %edi
f0100efa:	5d                   	pop    %ebp
f0100efb:	c3                   	ret    

f0100efc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100efc:	55                   	push   %ebp
f0100efd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100eff:	83 fa 01             	cmp    $0x1,%edx
f0100f02:	7e 0e                	jle    f0100f12 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100f04:	8b 10                	mov    (%eax),%edx
f0100f06:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100f09:	89 08                	mov    %ecx,(%eax)
f0100f0b:	8b 02                	mov    (%edx),%eax
f0100f0d:	8b 52 04             	mov    0x4(%edx),%edx
f0100f10:	eb 22                	jmp    f0100f34 <getuint+0x38>
	else if (lflag)
f0100f12:	85 d2                	test   %edx,%edx
f0100f14:	74 10                	je     f0100f26 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100f16:	8b 10                	mov    (%eax),%edx
f0100f18:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f1b:	89 08                	mov    %ecx,(%eax)
f0100f1d:	8b 02                	mov    (%edx),%eax
f0100f1f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f24:	eb 0e                	jmp    f0100f34 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100f26:	8b 10                	mov    (%eax),%edx
f0100f28:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f2b:	89 08                	mov    %ecx,(%eax)
f0100f2d:	8b 02                	mov    (%edx),%eax
f0100f2f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100f34:	5d                   	pop    %ebp
f0100f35:	c3                   	ret    

f0100f36 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f36:	55                   	push   %ebp
f0100f37:	89 e5                	mov    %esp,%ebp
f0100f39:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f3c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f40:	8b 10                	mov    (%eax),%edx
f0100f42:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f45:	73 0a                	jae    f0100f51 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f47:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f4a:	89 08                	mov    %ecx,(%eax)
f0100f4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f4f:	88 02                	mov    %al,(%edx)
}
f0100f51:	5d                   	pop    %ebp
f0100f52:	c3                   	ret    

f0100f53 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f53:	55                   	push   %ebp
f0100f54:	89 e5                	mov    %esp,%ebp
f0100f56:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100f59:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f5c:	50                   	push   %eax
f0100f5d:	ff 75 10             	pushl  0x10(%ebp)
f0100f60:	ff 75 0c             	pushl  0xc(%ebp)
f0100f63:	ff 75 08             	pushl  0x8(%ebp)
f0100f66:	e8 05 00 00 00       	call   f0100f70 <vprintfmt>
	va_end(ap);
}
f0100f6b:	83 c4 10             	add    $0x10,%esp
f0100f6e:	c9                   	leave  
f0100f6f:	c3                   	ret    

f0100f70 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100f70:	55                   	push   %ebp
f0100f71:	89 e5                	mov    %esp,%ebp
f0100f73:	57                   	push   %edi
f0100f74:	56                   	push   %esi
f0100f75:	53                   	push   %ebx
f0100f76:	83 ec 2c             	sub    $0x2c,%esp
f0100f79:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f7f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100f82:	eb 12                	jmp    f0100f96 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100f84:	85 c0                	test   %eax,%eax
f0100f86:	0f 84 89 03 00 00    	je     f0101315 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100f8c:	83 ec 08             	sub    $0x8,%esp
f0100f8f:	53                   	push   %ebx
f0100f90:	50                   	push   %eax
f0100f91:	ff d6                	call   *%esi
f0100f93:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f96:	83 c7 01             	add    $0x1,%edi
f0100f99:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100f9d:	83 f8 25             	cmp    $0x25,%eax
f0100fa0:	75 e2                	jne    f0100f84 <vprintfmt+0x14>
f0100fa2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100fa6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100fad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100fb4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100fbb:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fc0:	eb 07                	jmp    f0100fc9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100fc5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fc9:	8d 47 01             	lea    0x1(%edi),%eax
f0100fcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fcf:	0f b6 07             	movzbl (%edi),%eax
f0100fd2:	0f b6 c8             	movzbl %al,%ecx
f0100fd5:	83 e8 23             	sub    $0x23,%eax
f0100fd8:	3c 55                	cmp    $0x55,%al
f0100fda:	0f 87 1a 03 00 00    	ja     f01012fa <vprintfmt+0x38a>
f0100fe0:	0f b6 c0             	movzbl %al,%eax
f0100fe3:	ff 24 85 00 21 10 f0 	jmp    *-0xfefdf00(,%eax,4)
f0100fea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100fed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100ff1:	eb d6                	jmp    f0100fc9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ff3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ff6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ffb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100ffe:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101001:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0101005:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0101008:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010100b:	83 fa 09             	cmp    $0x9,%edx
f010100e:	77 39                	ja     f0101049 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101010:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101013:	eb e9                	jmp    f0100ffe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101015:	8b 45 14             	mov    0x14(%ebp),%eax
f0101018:	8d 48 04             	lea    0x4(%eax),%ecx
f010101b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010101e:	8b 00                	mov    (%eax),%eax
f0101020:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101023:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101026:	eb 27                	jmp    f010104f <vprintfmt+0xdf>
f0101028:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010102b:	85 c0                	test   %eax,%eax
f010102d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101032:	0f 49 c8             	cmovns %eax,%ecx
f0101035:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101038:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010103b:	eb 8c                	jmp    f0100fc9 <vprintfmt+0x59>
f010103d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101040:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101047:	eb 80                	jmp    f0100fc9 <vprintfmt+0x59>
f0101049:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010104c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010104f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101053:	0f 89 70 ff ff ff    	jns    f0100fc9 <vprintfmt+0x59>
				width = precision, precision = -1;
f0101059:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010105c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010105f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101066:	e9 5e ff ff ff       	jmp    f0100fc9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010106b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010106e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101071:	e9 53 ff ff ff       	jmp    f0100fc9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101076:	8b 45 14             	mov    0x14(%ebp),%eax
f0101079:	8d 50 04             	lea    0x4(%eax),%edx
f010107c:	89 55 14             	mov    %edx,0x14(%ebp)
f010107f:	83 ec 08             	sub    $0x8,%esp
f0101082:	53                   	push   %ebx
f0101083:	ff 30                	pushl  (%eax)
f0101085:	ff d6                	call   *%esi
			break;
f0101087:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010108a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010108d:	e9 04 ff ff ff       	jmp    f0100f96 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101092:	8b 45 14             	mov    0x14(%ebp),%eax
f0101095:	8d 50 04             	lea    0x4(%eax),%edx
f0101098:	89 55 14             	mov    %edx,0x14(%ebp)
f010109b:	8b 00                	mov    (%eax),%eax
f010109d:	99                   	cltd   
f010109e:	31 d0                	xor    %edx,%eax
f01010a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010a2:	83 f8 07             	cmp    $0x7,%eax
f01010a5:	7f 0b                	jg     f01010b2 <vprintfmt+0x142>
f01010a7:	8b 14 85 60 22 10 f0 	mov    -0xfefdda0(,%eax,4),%edx
f01010ae:	85 d2                	test   %edx,%edx
f01010b0:	75 18                	jne    f01010ca <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01010b2:	50                   	push   %eax
f01010b3:	68 75 20 10 f0       	push   $0xf0102075
f01010b8:	53                   	push   %ebx
f01010b9:	56                   	push   %esi
f01010ba:	e8 94 fe ff ff       	call   f0100f53 <printfmt>
f01010bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01010c5:	e9 cc fe ff ff       	jmp    f0100f96 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01010ca:	52                   	push   %edx
f01010cb:	68 7e 20 10 f0       	push   $0xf010207e
f01010d0:	53                   	push   %ebx
f01010d1:	56                   	push   %esi
f01010d2:	e8 7c fe ff ff       	call   f0100f53 <printfmt>
f01010d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010dd:	e9 b4 fe ff ff       	jmp    f0100f96 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01010e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e5:	8d 50 04             	lea    0x4(%eax),%edx
f01010e8:	89 55 14             	mov    %edx,0x14(%ebp)
f01010eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01010ed:	85 ff                	test   %edi,%edi
f01010ef:	b8 6e 20 10 f0       	mov    $0xf010206e,%eax
f01010f4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01010f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01010fb:	0f 8e 94 00 00 00    	jle    f0101195 <vprintfmt+0x225>
f0101101:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101105:	0f 84 98 00 00 00    	je     f01011a3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f010110b:	83 ec 08             	sub    $0x8,%esp
f010110e:	ff 75 d0             	pushl  -0x30(%ebp)
f0101111:	57                   	push   %edi
f0101112:	e8 5f 03 00 00       	call   f0101476 <strnlen>
f0101117:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010111a:	29 c1                	sub    %eax,%ecx
f010111c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010111f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101122:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101126:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101129:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010112c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010112e:	eb 0f                	jmp    f010113f <vprintfmt+0x1cf>
					putch(padc, putdat);
f0101130:	83 ec 08             	sub    $0x8,%esp
f0101133:	53                   	push   %ebx
f0101134:	ff 75 e0             	pushl  -0x20(%ebp)
f0101137:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101139:	83 ef 01             	sub    $0x1,%edi
f010113c:	83 c4 10             	add    $0x10,%esp
f010113f:	85 ff                	test   %edi,%edi
f0101141:	7f ed                	jg     f0101130 <vprintfmt+0x1c0>
f0101143:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101146:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101149:	85 c9                	test   %ecx,%ecx
f010114b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101150:	0f 49 c1             	cmovns %ecx,%eax
f0101153:	29 c1                	sub    %eax,%ecx
f0101155:	89 75 08             	mov    %esi,0x8(%ebp)
f0101158:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010115b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010115e:	89 cb                	mov    %ecx,%ebx
f0101160:	eb 4d                	jmp    f01011af <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101162:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101166:	74 1b                	je     f0101183 <vprintfmt+0x213>
f0101168:	0f be c0             	movsbl %al,%eax
f010116b:	83 e8 20             	sub    $0x20,%eax
f010116e:	83 f8 5e             	cmp    $0x5e,%eax
f0101171:	76 10                	jbe    f0101183 <vprintfmt+0x213>
					putch('?', putdat);
f0101173:	83 ec 08             	sub    $0x8,%esp
f0101176:	ff 75 0c             	pushl  0xc(%ebp)
f0101179:	6a 3f                	push   $0x3f
f010117b:	ff 55 08             	call   *0x8(%ebp)
f010117e:	83 c4 10             	add    $0x10,%esp
f0101181:	eb 0d                	jmp    f0101190 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101183:	83 ec 08             	sub    $0x8,%esp
f0101186:	ff 75 0c             	pushl  0xc(%ebp)
f0101189:	52                   	push   %edx
f010118a:	ff 55 08             	call   *0x8(%ebp)
f010118d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101190:	83 eb 01             	sub    $0x1,%ebx
f0101193:	eb 1a                	jmp    f01011af <vprintfmt+0x23f>
f0101195:	89 75 08             	mov    %esi,0x8(%ebp)
f0101198:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010119b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010119e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01011a1:	eb 0c                	jmp    f01011af <vprintfmt+0x23f>
f01011a3:	89 75 08             	mov    %esi,0x8(%ebp)
f01011a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01011a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01011ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01011af:	83 c7 01             	add    $0x1,%edi
f01011b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01011b6:	0f be d0             	movsbl %al,%edx
f01011b9:	85 d2                	test   %edx,%edx
f01011bb:	74 23                	je     f01011e0 <vprintfmt+0x270>
f01011bd:	85 f6                	test   %esi,%esi
f01011bf:	78 a1                	js     f0101162 <vprintfmt+0x1f2>
f01011c1:	83 ee 01             	sub    $0x1,%esi
f01011c4:	79 9c                	jns    f0101162 <vprintfmt+0x1f2>
f01011c6:	89 df                	mov    %ebx,%edi
f01011c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01011cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011ce:	eb 18                	jmp    f01011e8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01011d0:	83 ec 08             	sub    $0x8,%esp
f01011d3:	53                   	push   %ebx
f01011d4:	6a 20                	push   $0x20
f01011d6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01011d8:	83 ef 01             	sub    $0x1,%edi
f01011db:	83 c4 10             	add    $0x10,%esp
f01011de:	eb 08                	jmp    f01011e8 <vprintfmt+0x278>
f01011e0:	89 df                	mov    %ebx,%edi
f01011e2:	8b 75 08             	mov    0x8(%ebp),%esi
f01011e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011e8:	85 ff                	test   %edi,%edi
f01011ea:	7f e4                	jg     f01011d0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011ef:	e9 a2 fd ff ff       	jmp    f0100f96 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01011f4:	83 fa 01             	cmp    $0x1,%edx
f01011f7:	7e 16                	jle    f010120f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01011f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01011fc:	8d 50 08             	lea    0x8(%eax),%edx
f01011ff:	89 55 14             	mov    %edx,0x14(%ebp)
f0101202:	8b 50 04             	mov    0x4(%eax),%edx
f0101205:	8b 00                	mov    (%eax),%eax
f0101207:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010120a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010120d:	eb 32                	jmp    f0101241 <vprintfmt+0x2d1>
	else if (lflag)
f010120f:	85 d2                	test   %edx,%edx
f0101211:	74 18                	je     f010122b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101213:	8b 45 14             	mov    0x14(%ebp),%eax
f0101216:	8d 50 04             	lea    0x4(%eax),%edx
f0101219:	89 55 14             	mov    %edx,0x14(%ebp)
f010121c:	8b 00                	mov    (%eax),%eax
f010121e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101221:	89 c1                	mov    %eax,%ecx
f0101223:	c1 f9 1f             	sar    $0x1f,%ecx
f0101226:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101229:	eb 16                	jmp    f0101241 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010122b:	8b 45 14             	mov    0x14(%ebp),%eax
f010122e:	8d 50 04             	lea    0x4(%eax),%edx
f0101231:	89 55 14             	mov    %edx,0x14(%ebp)
f0101234:	8b 00                	mov    (%eax),%eax
f0101236:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101239:	89 c1                	mov    %eax,%ecx
f010123b:	c1 f9 1f             	sar    $0x1f,%ecx
f010123e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101241:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101244:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101247:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010124c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101250:	79 74                	jns    f01012c6 <vprintfmt+0x356>
				putch('-', putdat);
f0101252:	83 ec 08             	sub    $0x8,%esp
f0101255:	53                   	push   %ebx
f0101256:	6a 2d                	push   $0x2d
f0101258:	ff d6                	call   *%esi
				num = -(long long) num;
f010125a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010125d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101260:	f7 d8                	neg    %eax
f0101262:	83 d2 00             	adc    $0x0,%edx
f0101265:	f7 da                	neg    %edx
f0101267:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010126a:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010126f:	eb 55                	jmp    f01012c6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101271:	8d 45 14             	lea    0x14(%ebp),%eax
f0101274:	e8 83 fc ff ff       	call   f0100efc <getuint>
			base = 10;
f0101279:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010127e:	eb 46                	jmp    f01012c6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0101280:	8d 45 14             	lea    0x14(%ebp),%eax
f0101283:	e8 74 fc ff ff       	call   f0100efc <getuint>
			base = 8;
f0101288:	b9 08 00 00 00       	mov    $0x8,%ecx
			//putch('\\',putdat);
			goto number;
f010128d:	eb 37                	jmp    f01012c6 <vprintfmt+0x356>
			//putch('X', putdat);
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010128f:	83 ec 08             	sub    $0x8,%esp
f0101292:	53                   	push   %ebx
f0101293:	6a 30                	push   $0x30
f0101295:	ff d6                	call   *%esi
			putch('x', putdat);
f0101297:	83 c4 08             	add    $0x8,%esp
f010129a:	53                   	push   %ebx
f010129b:	6a 78                	push   $0x78
f010129d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010129f:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a2:	8d 50 04             	lea    0x4(%eax),%edx
f01012a5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01012a8:	8b 00                	mov    (%eax),%eax
f01012aa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01012af:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01012b2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01012b7:	eb 0d                	jmp    f01012c6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01012b9:	8d 45 14             	lea    0x14(%ebp),%eax
f01012bc:	e8 3b fc ff ff       	call   f0100efc <getuint>
			base = 16;
f01012c1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01012c6:	83 ec 0c             	sub    $0xc,%esp
f01012c9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01012cd:	57                   	push   %edi
f01012ce:	ff 75 e0             	pushl  -0x20(%ebp)
f01012d1:	51                   	push   %ecx
f01012d2:	52                   	push   %edx
f01012d3:	50                   	push   %eax
f01012d4:	89 da                	mov    %ebx,%edx
f01012d6:	89 f0                	mov    %esi,%eax
f01012d8:	e8 70 fb ff ff       	call   f0100e4d <printnum>
			break;
f01012dd:	83 c4 20             	add    $0x20,%esp
f01012e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01012e3:	e9 ae fc ff ff       	jmp    f0100f96 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01012e8:	83 ec 08             	sub    $0x8,%esp
f01012eb:	53                   	push   %ebx
f01012ec:	51                   	push   %ecx
f01012ed:	ff d6                	call   *%esi
			break;
f01012ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01012f5:	e9 9c fc ff ff       	jmp    f0100f96 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01012fa:	83 ec 08             	sub    $0x8,%esp
f01012fd:	53                   	push   %ebx
f01012fe:	6a 25                	push   $0x25
f0101300:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101302:	83 c4 10             	add    $0x10,%esp
f0101305:	eb 03                	jmp    f010130a <vprintfmt+0x39a>
f0101307:	83 ef 01             	sub    $0x1,%edi
f010130a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010130e:	75 f7                	jne    f0101307 <vprintfmt+0x397>
f0101310:	e9 81 fc ff ff       	jmp    f0100f96 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101315:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101318:	5b                   	pop    %ebx
f0101319:	5e                   	pop    %esi
f010131a:	5f                   	pop    %edi
f010131b:	5d                   	pop    %ebp
f010131c:	c3                   	ret    

f010131d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010131d:	55                   	push   %ebp
f010131e:	89 e5                	mov    %esp,%ebp
f0101320:	83 ec 18             	sub    $0x18,%esp
f0101323:	8b 45 08             	mov    0x8(%ebp),%eax
f0101326:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101329:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010132c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101330:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101333:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010133a:	85 c0                	test   %eax,%eax
f010133c:	74 26                	je     f0101364 <vsnprintf+0x47>
f010133e:	85 d2                	test   %edx,%edx
f0101340:	7e 22                	jle    f0101364 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101342:	ff 75 14             	pushl  0x14(%ebp)
f0101345:	ff 75 10             	pushl  0x10(%ebp)
f0101348:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010134b:	50                   	push   %eax
f010134c:	68 36 0f 10 f0       	push   $0xf0100f36
f0101351:	e8 1a fc ff ff       	call   f0100f70 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101356:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101359:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010135f:	83 c4 10             	add    $0x10,%esp
f0101362:	eb 05                	jmp    f0101369 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101369:	c9                   	leave  
f010136a:	c3                   	ret    

f010136b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010136b:	55                   	push   %ebp
f010136c:	89 e5                	mov    %esp,%ebp
f010136e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101371:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101374:	50                   	push   %eax
f0101375:	ff 75 10             	pushl  0x10(%ebp)
f0101378:	ff 75 0c             	pushl  0xc(%ebp)
f010137b:	ff 75 08             	pushl  0x8(%ebp)
f010137e:	e8 9a ff ff ff       	call   f010131d <vsnprintf>
	va_end(ap);

	return rc;
}
f0101383:	c9                   	leave  
f0101384:	c3                   	ret    

f0101385 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101385:	55                   	push   %ebp
f0101386:	89 e5                	mov    %esp,%ebp
f0101388:	57                   	push   %edi
f0101389:	56                   	push   %esi
f010138a:	53                   	push   %ebx
f010138b:	83 ec 0c             	sub    $0xc,%esp
f010138e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101391:	85 c0                	test   %eax,%eax
f0101393:	74 11                	je     f01013a6 <readline+0x21>
		cprintf("%s", prompt);
f0101395:	83 ec 08             	sub    $0x8,%esp
f0101398:	50                   	push   %eax
f0101399:	68 7e 20 10 f0       	push   $0xf010207e
f010139e:	e8 80 f7 ff ff       	call   f0100b23 <cprintf>
f01013a3:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01013a6:	83 ec 0c             	sub    $0xc,%esp
f01013a9:	6a 00                	push   $0x0
f01013ab:	e8 a0 f2 ff ff       	call   f0100650 <iscons>
f01013b0:	89 c7                	mov    %eax,%edi
f01013b2:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01013b5:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01013ba:	e8 80 f2 ff ff       	call   f010063f <getchar>
f01013bf:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01013c1:	85 c0                	test   %eax,%eax
f01013c3:	79 18                	jns    f01013dd <readline+0x58>
			cprintf("read error: %e\n", c);
f01013c5:	83 ec 08             	sub    $0x8,%esp
f01013c8:	50                   	push   %eax
f01013c9:	68 80 22 10 f0       	push   $0xf0102280
f01013ce:	e8 50 f7 ff ff       	call   f0100b23 <cprintf>
			return NULL;
f01013d3:	83 c4 10             	add    $0x10,%esp
f01013d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013db:	eb 79                	jmp    f0101456 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013dd:	83 f8 08             	cmp    $0x8,%eax
f01013e0:	0f 94 c2             	sete   %dl
f01013e3:	83 f8 7f             	cmp    $0x7f,%eax
f01013e6:	0f 94 c0             	sete   %al
f01013e9:	08 c2                	or     %al,%dl
f01013eb:	74 1a                	je     f0101407 <readline+0x82>
f01013ed:	85 f6                	test   %esi,%esi
f01013ef:	7e 16                	jle    f0101407 <readline+0x82>
			if (echoing)
f01013f1:	85 ff                	test   %edi,%edi
f01013f3:	74 0d                	je     f0101402 <readline+0x7d>
				cputchar('\b');
f01013f5:	83 ec 0c             	sub    $0xc,%esp
f01013f8:	6a 08                	push   $0x8
f01013fa:	e8 30 f2 ff ff       	call   f010062f <cputchar>
f01013ff:	83 c4 10             	add    $0x10,%esp
			i--;
f0101402:	83 ee 01             	sub    $0x1,%esi
f0101405:	eb b3                	jmp    f01013ba <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101407:	83 fb 1f             	cmp    $0x1f,%ebx
f010140a:	7e 23                	jle    f010142f <readline+0xaa>
f010140c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101412:	7f 1b                	jg     f010142f <readline+0xaa>
			if (echoing)
f0101414:	85 ff                	test   %edi,%edi
f0101416:	74 0c                	je     f0101424 <readline+0x9f>
				cputchar(c);
f0101418:	83 ec 0c             	sub    $0xc,%esp
f010141b:	53                   	push   %ebx
f010141c:	e8 0e f2 ff ff       	call   f010062f <cputchar>
f0101421:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101424:	88 9e 40 35 11 f0    	mov    %bl,-0xfeecac0(%esi)
f010142a:	8d 76 01             	lea    0x1(%esi),%esi
f010142d:	eb 8b                	jmp    f01013ba <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010142f:	83 fb 0a             	cmp    $0xa,%ebx
f0101432:	74 05                	je     f0101439 <readline+0xb4>
f0101434:	83 fb 0d             	cmp    $0xd,%ebx
f0101437:	75 81                	jne    f01013ba <readline+0x35>
			if (echoing)
f0101439:	85 ff                	test   %edi,%edi
f010143b:	74 0d                	je     f010144a <readline+0xc5>
				cputchar('\n');
f010143d:	83 ec 0c             	sub    $0xc,%esp
f0101440:	6a 0a                	push   $0xa
f0101442:	e8 e8 f1 ff ff       	call   f010062f <cputchar>
f0101447:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010144a:	c6 86 40 35 11 f0 00 	movb   $0x0,-0xfeecac0(%esi)
			return buf;
f0101451:	b8 40 35 11 f0       	mov    $0xf0113540,%eax
		}
	}
}
f0101456:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101459:	5b                   	pop    %ebx
f010145a:	5e                   	pop    %esi
f010145b:	5f                   	pop    %edi
f010145c:	5d                   	pop    %ebp
f010145d:	c3                   	ret    

f010145e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010145e:	55                   	push   %ebp
f010145f:	89 e5                	mov    %esp,%ebp
f0101461:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101464:	b8 00 00 00 00       	mov    $0x0,%eax
f0101469:	eb 03                	jmp    f010146e <strlen+0x10>
		n++;
f010146b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010146e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101472:	75 f7                	jne    f010146b <strlen+0xd>
		n++;
	return n;
}
f0101474:	5d                   	pop    %ebp
f0101475:	c3                   	ret    

f0101476 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010147c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010147f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101484:	eb 03                	jmp    f0101489 <strnlen+0x13>
		n++;
f0101486:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101489:	39 c2                	cmp    %eax,%edx
f010148b:	74 08                	je     f0101495 <strnlen+0x1f>
f010148d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101491:	75 f3                	jne    f0101486 <strnlen+0x10>
f0101493:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101495:	5d                   	pop    %ebp
f0101496:	c3                   	ret    

f0101497 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101497:	55                   	push   %ebp
f0101498:	89 e5                	mov    %esp,%ebp
f010149a:	53                   	push   %ebx
f010149b:	8b 45 08             	mov    0x8(%ebp),%eax
f010149e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01014a1:	89 c2                	mov    %eax,%edx
f01014a3:	83 c2 01             	add    $0x1,%edx
f01014a6:	83 c1 01             	add    $0x1,%ecx
f01014a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01014ad:	88 5a ff             	mov    %bl,-0x1(%edx)
f01014b0:	84 db                	test   %bl,%bl
f01014b2:	75 ef                	jne    f01014a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01014b4:	5b                   	pop    %ebx
f01014b5:	5d                   	pop    %ebp
f01014b6:	c3                   	ret    

f01014b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01014b7:	55                   	push   %ebp
f01014b8:	89 e5                	mov    %esp,%ebp
f01014ba:	53                   	push   %ebx
f01014bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01014be:	53                   	push   %ebx
f01014bf:	e8 9a ff ff ff       	call   f010145e <strlen>
f01014c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01014c7:	ff 75 0c             	pushl  0xc(%ebp)
f01014ca:	01 d8                	add    %ebx,%eax
f01014cc:	50                   	push   %eax
f01014cd:	e8 c5 ff ff ff       	call   f0101497 <strcpy>
	return dst;
}
f01014d2:	89 d8                	mov    %ebx,%eax
f01014d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014d7:	c9                   	leave  
f01014d8:	c3                   	ret    

f01014d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014d9:	55                   	push   %ebp
f01014da:	89 e5                	mov    %esp,%ebp
f01014dc:	56                   	push   %esi
f01014dd:	53                   	push   %ebx
f01014de:	8b 75 08             	mov    0x8(%ebp),%esi
f01014e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014e4:	89 f3                	mov    %esi,%ebx
f01014e6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014e9:	89 f2                	mov    %esi,%edx
f01014eb:	eb 0f                	jmp    f01014fc <strncpy+0x23>
		*dst++ = *src;
f01014ed:	83 c2 01             	add    $0x1,%edx
f01014f0:	0f b6 01             	movzbl (%ecx),%eax
f01014f3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014f6:	80 39 01             	cmpb   $0x1,(%ecx)
f01014f9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014fc:	39 da                	cmp    %ebx,%edx
f01014fe:	75 ed                	jne    f01014ed <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101500:	89 f0                	mov    %esi,%eax
f0101502:	5b                   	pop    %ebx
f0101503:	5e                   	pop    %esi
f0101504:	5d                   	pop    %ebp
f0101505:	c3                   	ret    

f0101506 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101506:	55                   	push   %ebp
f0101507:	89 e5                	mov    %esp,%ebp
f0101509:	56                   	push   %esi
f010150a:	53                   	push   %ebx
f010150b:	8b 75 08             	mov    0x8(%ebp),%esi
f010150e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101511:	8b 55 10             	mov    0x10(%ebp),%edx
f0101514:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101516:	85 d2                	test   %edx,%edx
f0101518:	74 21                	je     f010153b <strlcpy+0x35>
f010151a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010151e:	89 f2                	mov    %esi,%edx
f0101520:	eb 09                	jmp    f010152b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101522:	83 c2 01             	add    $0x1,%edx
f0101525:	83 c1 01             	add    $0x1,%ecx
f0101528:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010152b:	39 c2                	cmp    %eax,%edx
f010152d:	74 09                	je     f0101538 <strlcpy+0x32>
f010152f:	0f b6 19             	movzbl (%ecx),%ebx
f0101532:	84 db                	test   %bl,%bl
f0101534:	75 ec                	jne    f0101522 <strlcpy+0x1c>
f0101536:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101538:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010153b:	29 f0                	sub    %esi,%eax
}
f010153d:	5b                   	pop    %ebx
f010153e:	5e                   	pop    %esi
f010153f:	5d                   	pop    %ebp
f0101540:	c3                   	ret    

f0101541 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101541:	55                   	push   %ebp
f0101542:	89 e5                	mov    %esp,%ebp
f0101544:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101547:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010154a:	eb 06                	jmp    f0101552 <strcmp+0x11>
		p++, q++;
f010154c:	83 c1 01             	add    $0x1,%ecx
f010154f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101552:	0f b6 01             	movzbl (%ecx),%eax
f0101555:	84 c0                	test   %al,%al
f0101557:	74 04                	je     f010155d <strcmp+0x1c>
f0101559:	3a 02                	cmp    (%edx),%al
f010155b:	74 ef                	je     f010154c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010155d:	0f b6 c0             	movzbl %al,%eax
f0101560:	0f b6 12             	movzbl (%edx),%edx
f0101563:	29 d0                	sub    %edx,%eax
}
f0101565:	5d                   	pop    %ebp
f0101566:	c3                   	ret    

f0101567 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101567:	55                   	push   %ebp
f0101568:	89 e5                	mov    %esp,%ebp
f010156a:	53                   	push   %ebx
f010156b:	8b 45 08             	mov    0x8(%ebp),%eax
f010156e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101571:	89 c3                	mov    %eax,%ebx
f0101573:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101576:	eb 06                	jmp    f010157e <strncmp+0x17>
		n--, p++, q++;
f0101578:	83 c0 01             	add    $0x1,%eax
f010157b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010157e:	39 d8                	cmp    %ebx,%eax
f0101580:	74 15                	je     f0101597 <strncmp+0x30>
f0101582:	0f b6 08             	movzbl (%eax),%ecx
f0101585:	84 c9                	test   %cl,%cl
f0101587:	74 04                	je     f010158d <strncmp+0x26>
f0101589:	3a 0a                	cmp    (%edx),%cl
f010158b:	74 eb                	je     f0101578 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010158d:	0f b6 00             	movzbl (%eax),%eax
f0101590:	0f b6 12             	movzbl (%edx),%edx
f0101593:	29 d0                	sub    %edx,%eax
f0101595:	eb 05                	jmp    f010159c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101597:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010159c:	5b                   	pop    %ebx
f010159d:	5d                   	pop    %ebp
f010159e:	c3                   	ret    

f010159f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010159f:	55                   	push   %ebp
f01015a0:	89 e5                	mov    %esp,%ebp
f01015a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015a9:	eb 07                	jmp    f01015b2 <strchr+0x13>
		if (*s == c)
f01015ab:	38 ca                	cmp    %cl,%dl
f01015ad:	74 0f                	je     f01015be <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01015af:	83 c0 01             	add    $0x1,%eax
f01015b2:	0f b6 10             	movzbl (%eax),%edx
f01015b5:	84 d2                	test   %dl,%dl
f01015b7:	75 f2                	jne    f01015ab <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01015b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015be:	5d                   	pop    %ebp
f01015bf:	c3                   	ret    

f01015c0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01015c0:	55                   	push   %ebp
f01015c1:	89 e5                	mov    %esp,%ebp
f01015c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01015c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015ca:	eb 03                	jmp    f01015cf <strfind+0xf>
f01015cc:	83 c0 01             	add    $0x1,%eax
f01015cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01015d2:	38 ca                	cmp    %cl,%dl
f01015d4:	74 04                	je     f01015da <strfind+0x1a>
f01015d6:	84 d2                	test   %dl,%dl
f01015d8:	75 f2                	jne    f01015cc <strfind+0xc>
			break;
	return (char *) s;
}
f01015da:	5d                   	pop    %ebp
f01015db:	c3                   	ret    

f01015dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015dc:	55                   	push   %ebp
f01015dd:	89 e5                	mov    %esp,%ebp
f01015df:	57                   	push   %edi
f01015e0:	56                   	push   %esi
f01015e1:	53                   	push   %ebx
f01015e2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015e8:	85 c9                	test   %ecx,%ecx
f01015ea:	74 36                	je     f0101622 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015f2:	75 28                	jne    f010161c <memset+0x40>
f01015f4:	f6 c1 03             	test   $0x3,%cl
f01015f7:	75 23                	jne    f010161c <memset+0x40>
		c &= 0xFF;
f01015f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015fd:	89 d3                	mov    %edx,%ebx
f01015ff:	c1 e3 08             	shl    $0x8,%ebx
f0101602:	89 d6                	mov    %edx,%esi
f0101604:	c1 e6 18             	shl    $0x18,%esi
f0101607:	89 d0                	mov    %edx,%eax
f0101609:	c1 e0 10             	shl    $0x10,%eax
f010160c:	09 f0                	or     %esi,%eax
f010160e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101610:	89 d8                	mov    %ebx,%eax
f0101612:	09 d0                	or     %edx,%eax
f0101614:	c1 e9 02             	shr    $0x2,%ecx
f0101617:	fc                   	cld    
f0101618:	f3 ab                	rep stos %eax,%es:(%edi)
f010161a:	eb 06                	jmp    f0101622 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010161c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010161f:	fc                   	cld    
f0101620:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101622:	89 f8                	mov    %edi,%eax
f0101624:	5b                   	pop    %ebx
f0101625:	5e                   	pop    %esi
f0101626:	5f                   	pop    %edi
f0101627:	5d                   	pop    %ebp
f0101628:	c3                   	ret    

f0101629 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101629:	55                   	push   %ebp
f010162a:	89 e5                	mov    %esp,%ebp
f010162c:	57                   	push   %edi
f010162d:	56                   	push   %esi
f010162e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101631:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101634:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101637:	39 c6                	cmp    %eax,%esi
f0101639:	73 35                	jae    f0101670 <memmove+0x47>
f010163b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010163e:	39 d0                	cmp    %edx,%eax
f0101640:	73 2e                	jae    f0101670 <memmove+0x47>
		s += n;
		d += n;
f0101642:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101645:	89 d6                	mov    %edx,%esi
f0101647:	09 fe                	or     %edi,%esi
f0101649:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010164f:	75 13                	jne    f0101664 <memmove+0x3b>
f0101651:	f6 c1 03             	test   $0x3,%cl
f0101654:	75 0e                	jne    f0101664 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101656:	83 ef 04             	sub    $0x4,%edi
f0101659:	8d 72 fc             	lea    -0x4(%edx),%esi
f010165c:	c1 e9 02             	shr    $0x2,%ecx
f010165f:	fd                   	std    
f0101660:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101662:	eb 09                	jmp    f010166d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101664:	83 ef 01             	sub    $0x1,%edi
f0101667:	8d 72 ff             	lea    -0x1(%edx),%esi
f010166a:	fd                   	std    
f010166b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010166d:	fc                   	cld    
f010166e:	eb 1d                	jmp    f010168d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101670:	89 f2                	mov    %esi,%edx
f0101672:	09 c2                	or     %eax,%edx
f0101674:	f6 c2 03             	test   $0x3,%dl
f0101677:	75 0f                	jne    f0101688 <memmove+0x5f>
f0101679:	f6 c1 03             	test   $0x3,%cl
f010167c:	75 0a                	jne    f0101688 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010167e:	c1 e9 02             	shr    $0x2,%ecx
f0101681:	89 c7                	mov    %eax,%edi
f0101683:	fc                   	cld    
f0101684:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101686:	eb 05                	jmp    f010168d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101688:	89 c7                	mov    %eax,%edi
f010168a:	fc                   	cld    
f010168b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010168d:	5e                   	pop    %esi
f010168e:	5f                   	pop    %edi
f010168f:	5d                   	pop    %ebp
f0101690:	c3                   	ret    

f0101691 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101691:	55                   	push   %ebp
f0101692:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101694:	ff 75 10             	pushl  0x10(%ebp)
f0101697:	ff 75 0c             	pushl  0xc(%ebp)
f010169a:	ff 75 08             	pushl  0x8(%ebp)
f010169d:	e8 87 ff ff ff       	call   f0101629 <memmove>
}
f01016a2:	c9                   	leave  
f01016a3:	c3                   	ret    

f01016a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01016a4:	55                   	push   %ebp
f01016a5:	89 e5                	mov    %esp,%ebp
f01016a7:	56                   	push   %esi
f01016a8:	53                   	push   %ebx
f01016a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016af:	89 c6                	mov    %eax,%esi
f01016b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016b4:	eb 1a                	jmp    f01016d0 <memcmp+0x2c>
		if (*s1 != *s2)
f01016b6:	0f b6 08             	movzbl (%eax),%ecx
f01016b9:	0f b6 1a             	movzbl (%edx),%ebx
f01016bc:	38 d9                	cmp    %bl,%cl
f01016be:	74 0a                	je     f01016ca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01016c0:	0f b6 c1             	movzbl %cl,%eax
f01016c3:	0f b6 db             	movzbl %bl,%ebx
f01016c6:	29 d8                	sub    %ebx,%eax
f01016c8:	eb 0f                	jmp    f01016d9 <memcmp+0x35>
		s1++, s2++;
f01016ca:	83 c0 01             	add    $0x1,%eax
f01016cd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016d0:	39 f0                	cmp    %esi,%eax
f01016d2:	75 e2                	jne    f01016b6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01016d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016d9:	5b                   	pop    %ebx
f01016da:	5e                   	pop    %esi
f01016db:	5d                   	pop    %ebp
f01016dc:	c3                   	ret    

f01016dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016dd:	55                   	push   %ebp
f01016de:	89 e5                	mov    %esp,%ebp
f01016e0:	53                   	push   %ebx
f01016e1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01016e4:	89 c1                	mov    %eax,%ecx
f01016e6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01016e9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016ed:	eb 0a                	jmp    f01016f9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016ef:	0f b6 10             	movzbl (%eax),%edx
f01016f2:	39 da                	cmp    %ebx,%edx
f01016f4:	74 07                	je     f01016fd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016f6:	83 c0 01             	add    $0x1,%eax
f01016f9:	39 c8                	cmp    %ecx,%eax
f01016fb:	72 f2                	jb     f01016ef <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01016fd:	5b                   	pop    %ebx
f01016fe:	5d                   	pop    %ebp
f01016ff:	c3                   	ret    

f0101700 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101700:	55                   	push   %ebp
f0101701:	89 e5                	mov    %esp,%ebp
f0101703:	57                   	push   %edi
f0101704:	56                   	push   %esi
f0101705:	53                   	push   %ebx
f0101706:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101709:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010170c:	eb 03                	jmp    f0101711 <strtol+0x11>
		s++;
f010170e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101711:	0f b6 01             	movzbl (%ecx),%eax
f0101714:	3c 20                	cmp    $0x20,%al
f0101716:	74 f6                	je     f010170e <strtol+0xe>
f0101718:	3c 09                	cmp    $0x9,%al
f010171a:	74 f2                	je     f010170e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010171c:	3c 2b                	cmp    $0x2b,%al
f010171e:	75 0a                	jne    f010172a <strtol+0x2a>
		s++;
f0101720:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101723:	bf 00 00 00 00       	mov    $0x0,%edi
f0101728:	eb 11                	jmp    f010173b <strtol+0x3b>
f010172a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010172f:	3c 2d                	cmp    $0x2d,%al
f0101731:	75 08                	jne    f010173b <strtol+0x3b>
		s++, neg = 1;
f0101733:	83 c1 01             	add    $0x1,%ecx
f0101736:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010173b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101741:	75 15                	jne    f0101758 <strtol+0x58>
f0101743:	80 39 30             	cmpb   $0x30,(%ecx)
f0101746:	75 10                	jne    f0101758 <strtol+0x58>
f0101748:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010174c:	75 7c                	jne    f01017ca <strtol+0xca>
		s += 2, base = 16;
f010174e:	83 c1 02             	add    $0x2,%ecx
f0101751:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101756:	eb 16                	jmp    f010176e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101758:	85 db                	test   %ebx,%ebx
f010175a:	75 12                	jne    f010176e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010175c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101761:	80 39 30             	cmpb   $0x30,(%ecx)
f0101764:	75 08                	jne    f010176e <strtol+0x6e>
		s++, base = 8;
f0101766:	83 c1 01             	add    $0x1,%ecx
f0101769:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010176e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101773:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101776:	0f b6 11             	movzbl (%ecx),%edx
f0101779:	8d 72 d0             	lea    -0x30(%edx),%esi
f010177c:	89 f3                	mov    %esi,%ebx
f010177e:	80 fb 09             	cmp    $0x9,%bl
f0101781:	77 08                	ja     f010178b <strtol+0x8b>
			dig = *s - '0';
f0101783:	0f be d2             	movsbl %dl,%edx
f0101786:	83 ea 30             	sub    $0x30,%edx
f0101789:	eb 22                	jmp    f01017ad <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010178b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010178e:	89 f3                	mov    %esi,%ebx
f0101790:	80 fb 19             	cmp    $0x19,%bl
f0101793:	77 08                	ja     f010179d <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101795:	0f be d2             	movsbl %dl,%edx
f0101798:	83 ea 57             	sub    $0x57,%edx
f010179b:	eb 10                	jmp    f01017ad <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010179d:	8d 72 bf             	lea    -0x41(%edx),%esi
f01017a0:	89 f3                	mov    %esi,%ebx
f01017a2:	80 fb 19             	cmp    $0x19,%bl
f01017a5:	77 16                	ja     f01017bd <strtol+0xbd>
			dig = *s - 'A' + 10;
f01017a7:	0f be d2             	movsbl %dl,%edx
f01017aa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01017ad:	3b 55 10             	cmp    0x10(%ebp),%edx
f01017b0:	7d 0b                	jge    f01017bd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01017b2:	83 c1 01             	add    $0x1,%ecx
f01017b5:	0f af 45 10          	imul   0x10(%ebp),%eax
f01017b9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01017bb:	eb b9                	jmp    f0101776 <strtol+0x76>

	if (endptr)
f01017bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017c1:	74 0d                	je     f01017d0 <strtol+0xd0>
		*endptr = (char *) s;
f01017c3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017c6:	89 0e                	mov    %ecx,(%esi)
f01017c8:	eb 06                	jmp    f01017d0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01017ca:	85 db                	test   %ebx,%ebx
f01017cc:	74 98                	je     f0101766 <strtol+0x66>
f01017ce:	eb 9e                	jmp    f010176e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01017d0:	89 c2                	mov    %eax,%edx
f01017d2:	f7 da                	neg    %edx
f01017d4:	85 ff                	test   %edi,%edi
f01017d6:	0f 45 c2             	cmovne %edx,%eax
}
f01017d9:	5b                   	pop    %ebx
f01017da:	5e                   	pop    %esi
f01017db:	5f                   	pop    %edi
f01017dc:	5d                   	pop    %ebp
f01017dd:	c3                   	ret    
f01017de:	66 90                	xchg   %ax,%ax

f01017e0 <__udivdi3>:
f01017e0:	55                   	push   %ebp
f01017e1:	57                   	push   %edi
f01017e2:	56                   	push   %esi
f01017e3:	53                   	push   %ebx
f01017e4:	83 ec 1c             	sub    $0x1c,%esp
f01017e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01017eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01017ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01017f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017f7:	85 f6                	test   %esi,%esi
f01017f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01017fd:	89 ca                	mov    %ecx,%edx
f01017ff:	89 f8                	mov    %edi,%eax
f0101801:	75 3d                	jne    f0101840 <__udivdi3+0x60>
f0101803:	39 cf                	cmp    %ecx,%edi
f0101805:	0f 87 c5 00 00 00    	ja     f01018d0 <__udivdi3+0xf0>
f010180b:	85 ff                	test   %edi,%edi
f010180d:	89 fd                	mov    %edi,%ebp
f010180f:	75 0b                	jne    f010181c <__udivdi3+0x3c>
f0101811:	b8 01 00 00 00       	mov    $0x1,%eax
f0101816:	31 d2                	xor    %edx,%edx
f0101818:	f7 f7                	div    %edi
f010181a:	89 c5                	mov    %eax,%ebp
f010181c:	89 c8                	mov    %ecx,%eax
f010181e:	31 d2                	xor    %edx,%edx
f0101820:	f7 f5                	div    %ebp
f0101822:	89 c1                	mov    %eax,%ecx
f0101824:	89 d8                	mov    %ebx,%eax
f0101826:	89 cf                	mov    %ecx,%edi
f0101828:	f7 f5                	div    %ebp
f010182a:	89 c3                	mov    %eax,%ebx
f010182c:	89 d8                	mov    %ebx,%eax
f010182e:	89 fa                	mov    %edi,%edx
f0101830:	83 c4 1c             	add    $0x1c,%esp
f0101833:	5b                   	pop    %ebx
f0101834:	5e                   	pop    %esi
f0101835:	5f                   	pop    %edi
f0101836:	5d                   	pop    %ebp
f0101837:	c3                   	ret    
f0101838:	90                   	nop
f0101839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101840:	39 ce                	cmp    %ecx,%esi
f0101842:	77 74                	ja     f01018b8 <__udivdi3+0xd8>
f0101844:	0f bd fe             	bsr    %esi,%edi
f0101847:	83 f7 1f             	xor    $0x1f,%edi
f010184a:	0f 84 98 00 00 00    	je     f01018e8 <__udivdi3+0x108>
f0101850:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101855:	89 f9                	mov    %edi,%ecx
f0101857:	89 c5                	mov    %eax,%ebp
f0101859:	29 fb                	sub    %edi,%ebx
f010185b:	d3 e6                	shl    %cl,%esi
f010185d:	89 d9                	mov    %ebx,%ecx
f010185f:	d3 ed                	shr    %cl,%ebp
f0101861:	89 f9                	mov    %edi,%ecx
f0101863:	d3 e0                	shl    %cl,%eax
f0101865:	09 ee                	or     %ebp,%esi
f0101867:	89 d9                	mov    %ebx,%ecx
f0101869:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010186d:	89 d5                	mov    %edx,%ebp
f010186f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101873:	d3 ed                	shr    %cl,%ebp
f0101875:	89 f9                	mov    %edi,%ecx
f0101877:	d3 e2                	shl    %cl,%edx
f0101879:	89 d9                	mov    %ebx,%ecx
f010187b:	d3 e8                	shr    %cl,%eax
f010187d:	09 c2                	or     %eax,%edx
f010187f:	89 d0                	mov    %edx,%eax
f0101881:	89 ea                	mov    %ebp,%edx
f0101883:	f7 f6                	div    %esi
f0101885:	89 d5                	mov    %edx,%ebp
f0101887:	89 c3                	mov    %eax,%ebx
f0101889:	f7 64 24 0c          	mull   0xc(%esp)
f010188d:	39 d5                	cmp    %edx,%ebp
f010188f:	72 10                	jb     f01018a1 <__udivdi3+0xc1>
f0101891:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101895:	89 f9                	mov    %edi,%ecx
f0101897:	d3 e6                	shl    %cl,%esi
f0101899:	39 c6                	cmp    %eax,%esi
f010189b:	73 07                	jae    f01018a4 <__udivdi3+0xc4>
f010189d:	39 d5                	cmp    %edx,%ebp
f010189f:	75 03                	jne    f01018a4 <__udivdi3+0xc4>
f01018a1:	83 eb 01             	sub    $0x1,%ebx
f01018a4:	31 ff                	xor    %edi,%edi
f01018a6:	89 d8                	mov    %ebx,%eax
f01018a8:	89 fa                	mov    %edi,%edx
f01018aa:	83 c4 1c             	add    $0x1c,%esp
f01018ad:	5b                   	pop    %ebx
f01018ae:	5e                   	pop    %esi
f01018af:	5f                   	pop    %edi
f01018b0:	5d                   	pop    %ebp
f01018b1:	c3                   	ret    
f01018b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018b8:	31 ff                	xor    %edi,%edi
f01018ba:	31 db                	xor    %ebx,%ebx
f01018bc:	89 d8                	mov    %ebx,%eax
f01018be:	89 fa                	mov    %edi,%edx
f01018c0:	83 c4 1c             	add    $0x1c,%esp
f01018c3:	5b                   	pop    %ebx
f01018c4:	5e                   	pop    %esi
f01018c5:	5f                   	pop    %edi
f01018c6:	5d                   	pop    %ebp
f01018c7:	c3                   	ret    
f01018c8:	90                   	nop
f01018c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018d0:	89 d8                	mov    %ebx,%eax
f01018d2:	f7 f7                	div    %edi
f01018d4:	31 ff                	xor    %edi,%edi
f01018d6:	89 c3                	mov    %eax,%ebx
f01018d8:	89 d8                	mov    %ebx,%eax
f01018da:	89 fa                	mov    %edi,%edx
f01018dc:	83 c4 1c             	add    $0x1c,%esp
f01018df:	5b                   	pop    %ebx
f01018e0:	5e                   	pop    %esi
f01018e1:	5f                   	pop    %edi
f01018e2:	5d                   	pop    %ebp
f01018e3:	c3                   	ret    
f01018e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018e8:	39 ce                	cmp    %ecx,%esi
f01018ea:	72 0c                	jb     f01018f8 <__udivdi3+0x118>
f01018ec:	31 db                	xor    %ebx,%ebx
f01018ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01018f2:	0f 87 34 ff ff ff    	ja     f010182c <__udivdi3+0x4c>
f01018f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01018fd:	e9 2a ff ff ff       	jmp    f010182c <__udivdi3+0x4c>
f0101902:	66 90                	xchg   %ax,%ax
f0101904:	66 90                	xchg   %ax,%ax
f0101906:	66 90                	xchg   %ax,%ax
f0101908:	66 90                	xchg   %ax,%ax
f010190a:	66 90                	xchg   %ax,%ax
f010190c:	66 90                	xchg   %ax,%ax
f010190e:	66 90                	xchg   %ax,%ax

f0101910 <__umoddi3>:
f0101910:	55                   	push   %ebp
f0101911:	57                   	push   %edi
f0101912:	56                   	push   %esi
f0101913:	53                   	push   %ebx
f0101914:	83 ec 1c             	sub    $0x1c,%esp
f0101917:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010191b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010191f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101923:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101927:	85 d2                	test   %edx,%edx
f0101929:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010192d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101931:	89 f3                	mov    %esi,%ebx
f0101933:	89 3c 24             	mov    %edi,(%esp)
f0101936:	89 74 24 04          	mov    %esi,0x4(%esp)
f010193a:	75 1c                	jne    f0101958 <__umoddi3+0x48>
f010193c:	39 f7                	cmp    %esi,%edi
f010193e:	76 50                	jbe    f0101990 <__umoddi3+0x80>
f0101940:	89 c8                	mov    %ecx,%eax
f0101942:	89 f2                	mov    %esi,%edx
f0101944:	f7 f7                	div    %edi
f0101946:	89 d0                	mov    %edx,%eax
f0101948:	31 d2                	xor    %edx,%edx
f010194a:	83 c4 1c             	add    $0x1c,%esp
f010194d:	5b                   	pop    %ebx
f010194e:	5e                   	pop    %esi
f010194f:	5f                   	pop    %edi
f0101950:	5d                   	pop    %ebp
f0101951:	c3                   	ret    
f0101952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101958:	39 f2                	cmp    %esi,%edx
f010195a:	89 d0                	mov    %edx,%eax
f010195c:	77 52                	ja     f01019b0 <__umoddi3+0xa0>
f010195e:	0f bd ea             	bsr    %edx,%ebp
f0101961:	83 f5 1f             	xor    $0x1f,%ebp
f0101964:	75 5a                	jne    f01019c0 <__umoddi3+0xb0>
f0101966:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010196a:	0f 82 e0 00 00 00    	jb     f0101a50 <__umoddi3+0x140>
f0101970:	39 0c 24             	cmp    %ecx,(%esp)
f0101973:	0f 86 d7 00 00 00    	jbe    f0101a50 <__umoddi3+0x140>
f0101979:	8b 44 24 08          	mov    0x8(%esp),%eax
f010197d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101981:	83 c4 1c             	add    $0x1c,%esp
f0101984:	5b                   	pop    %ebx
f0101985:	5e                   	pop    %esi
f0101986:	5f                   	pop    %edi
f0101987:	5d                   	pop    %ebp
f0101988:	c3                   	ret    
f0101989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101990:	85 ff                	test   %edi,%edi
f0101992:	89 fd                	mov    %edi,%ebp
f0101994:	75 0b                	jne    f01019a1 <__umoddi3+0x91>
f0101996:	b8 01 00 00 00       	mov    $0x1,%eax
f010199b:	31 d2                	xor    %edx,%edx
f010199d:	f7 f7                	div    %edi
f010199f:	89 c5                	mov    %eax,%ebp
f01019a1:	89 f0                	mov    %esi,%eax
f01019a3:	31 d2                	xor    %edx,%edx
f01019a5:	f7 f5                	div    %ebp
f01019a7:	89 c8                	mov    %ecx,%eax
f01019a9:	f7 f5                	div    %ebp
f01019ab:	89 d0                	mov    %edx,%eax
f01019ad:	eb 99                	jmp    f0101948 <__umoddi3+0x38>
f01019af:	90                   	nop
f01019b0:	89 c8                	mov    %ecx,%eax
f01019b2:	89 f2                	mov    %esi,%edx
f01019b4:	83 c4 1c             	add    $0x1c,%esp
f01019b7:	5b                   	pop    %ebx
f01019b8:	5e                   	pop    %esi
f01019b9:	5f                   	pop    %edi
f01019ba:	5d                   	pop    %ebp
f01019bb:	c3                   	ret    
f01019bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019c0:	8b 34 24             	mov    (%esp),%esi
f01019c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01019c8:	89 e9                	mov    %ebp,%ecx
f01019ca:	29 ef                	sub    %ebp,%edi
f01019cc:	d3 e0                	shl    %cl,%eax
f01019ce:	89 f9                	mov    %edi,%ecx
f01019d0:	89 f2                	mov    %esi,%edx
f01019d2:	d3 ea                	shr    %cl,%edx
f01019d4:	89 e9                	mov    %ebp,%ecx
f01019d6:	09 c2                	or     %eax,%edx
f01019d8:	89 d8                	mov    %ebx,%eax
f01019da:	89 14 24             	mov    %edx,(%esp)
f01019dd:	89 f2                	mov    %esi,%edx
f01019df:	d3 e2                	shl    %cl,%edx
f01019e1:	89 f9                	mov    %edi,%ecx
f01019e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01019e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01019eb:	d3 e8                	shr    %cl,%eax
f01019ed:	89 e9                	mov    %ebp,%ecx
f01019ef:	89 c6                	mov    %eax,%esi
f01019f1:	d3 e3                	shl    %cl,%ebx
f01019f3:	89 f9                	mov    %edi,%ecx
f01019f5:	89 d0                	mov    %edx,%eax
f01019f7:	d3 e8                	shr    %cl,%eax
f01019f9:	89 e9                	mov    %ebp,%ecx
f01019fb:	09 d8                	or     %ebx,%eax
f01019fd:	89 d3                	mov    %edx,%ebx
f01019ff:	89 f2                	mov    %esi,%edx
f0101a01:	f7 34 24             	divl   (%esp)
f0101a04:	89 d6                	mov    %edx,%esi
f0101a06:	d3 e3                	shl    %cl,%ebx
f0101a08:	f7 64 24 04          	mull   0x4(%esp)
f0101a0c:	39 d6                	cmp    %edx,%esi
f0101a0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101a12:	89 d1                	mov    %edx,%ecx
f0101a14:	89 c3                	mov    %eax,%ebx
f0101a16:	72 08                	jb     f0101a20 <__umoddi3+0x110>
f0101a18:	75 11                	jne    f0101a2b <__umoddi3+0x11b>
f0101a1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101a1e:	73 0b                	jae    f0101a2b <__umoddi3+0x11b>
f0101a20:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101a24:	1b 14 24             	sbb    (%esp),%edx
f0101a27:	89 d1                	mov    %edx,%ecx
f0101a29:	89 c3                	mov    %eax,%ebx
f0101a2b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101a2f:	29 da                	sub    %ebx,%edx
f0101a31:	19 ce                	sbb    %ecx,%esi
f0101a33:	89 f9                	mov    %edi,%ecx
f0101a35:	89 f0                	mov    %esi,%eax
f0101a37:	d3 e0                	shl    %cl,%eax
f0101a39:	89 e9                	mov    %ebp,%ecx
f0101a3b:	d3 ea                	shr    %cl,%edx
f0101a3d:	89 e9                	mov    %ebp,%ecx
f0101a3f:	d3 ee                	shr    %cl,%esi
f0101a41:	09 d0                	or     %edx,%eax
f0101a43:	89 f2                	mov    %esi,%edx
f0101a45:	83 c4 1c             	add    $0x1c,%esp
f0101a48:	5b                   	pop    %ebx
f0101a49:	5e                   	pop    %esi
f0101a4a:	5f                   	pop    %edi
f0101a4b:	5d                   	pop    %ebp
f0101a4c:	c3                   	ret    
f0101a4d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a50:	29 f9                	sub    %edi,%ecx
f0101a52:	19 d6                	sbb    %edx,%esi
f0101a54:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101a58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a5c:	e9 18 ff ff ff       	jmp    f0101979 <__umoddi3+0x69>
